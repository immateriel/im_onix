require 'onix/identifier'

module ONIX
  class TitleElement < Subset
    attr_accessor :title_prefix, :title_without_prefix, :title_text, :subtitle

    def parse(title_element)
      @title_text=Helper.text_at(title_element, "./TitleText")

      @title_prefix=Helper.text_at(title_element, "./TitlePrefix")
      @title_without_prefix=Helper.text_at(title_element, "./TitleWithoutPrefix")
      @subtitle=Helper.text_at(title_element, "./Subtitle")
    end

    def title
      if @title_text
        @title_text
      else
        if @title_without_prefix
          if @title_prefix
            "#{@title_prefix} #{@title_without_prefix}"
          else
            @title_without_prefix
          end
        end
      end
    end
  end

  class TitleDetail < Subset
    attr_accessor :type, :title_elements

    def initialize
      @title_elements=[]
    end

    def parse(title_detail)
      @type=TitleType.from_code(title_detail.at("./TitleType").text)
      title_detail.search("./TitleElement").each do |title_element|
        @title_elements << TitleElement.from_xml(title_element)
      end
    end
  end

  class Collection < Subset
    attr_accessor :type, :identifiers, :title_details

    def initialize
      @identifiers=[]
      @title_details=[]
    end

    def parse(col)
      @type=CollectionType.from_code(col.at("./CollectionType"))
      @identifiers=Identifier.parse_identifiers(col,"Collection")

      col.search("./TitleDetail").each do |title_detail|
        @title_details << TitleDetail.from_xml(title_detail)
      end
    end
  end

  class ProductPart < Subset
    attr_accessor :identifiers, :form, :form_detail, :form_description,
                  :product


    include EanMethods

    def parse(ppart)
      @identifiers=Identifier.parse_identifiers(ppart,"Product")

      if ppart.at("./ProductForm")
        @form=ProductForm.from_code(ppart.at("./ProductForm").text)
      end

      if ppart.at("./ProductFormDescription")
        @form_description=ppart.at("./ProductFormDescription").text
      end

      if ppart.at("./ProductFormDetail")
        @form_detail=ProductFormDetail.from_code(ppart.at("./ProductFormDetail").text)
      end

    end
  end

class DescriptiveDetail < Subset
  attr_accessor :title_details, :collection, :language,
                :composition,
                :form, :form_detail, :form_description, :parts,
                :contributors,
                :subjects,
                :collections

  def initialize
    @title_details=[]
    @text_contents=[]
    @parts=[]
    @contributors=[]
    @subjects=[]
    @collections=[]
  end

  def title
    @title_details.select{|td| td.type.human=~/DistinctiveTitle/}.first.title_elements.first.title
  end

  def subtitle
    @title_details.select{|td| td.type.human=~/DistinctiveTitle/}.first.title_elements.first.subtitle
  end


  def parse(descriptive)

    descriptive.search("./TitleDetail").each do |title_detail|
      @title_details << TitleDetail.from_xml(title_detail)
    end

    descriptive.search("./Contributor").each do |c|
      @contributors << Contributor.from_xml(c)
    end

    descriptive.search("./Collection").each do |collection|
      @collections << Collection.from_xml(collection)
    end

    # TODO
    e_page_count=nil
    e_filesize=nil
    descriptive.search("./Extent").each do |e|
      case e.at("./ExtentType").text
        when "00", "03"
          e_page_count=e.at("./ExtentValue").text.to_i
        when "22"
          case e.at("./ExtentUnit").text
            when "17"
              e_filesize=e.at("./ExtentValue").text.to_i
            when "18"
              e_filesize=(e.at("./ExtentValue").text.to_f*1024).to_i
            when "19"
              e_filesize=(e.at("./ExtentValue").text.to_f*1024*1024).to_i
          end
      end
    end

    if descriptive.at("./Language/LanguageCode")
      @language=descriptive.at("./Language/LanguageCode").text
    end

    if descriptive.at("./ProductComposition")
      # mono-format
      if descriptive.at("./ProductForm")
        @form=ProductForm.from_code(descriptive.at("./ProductForm").text)
      end

      if descriptive.at("./ProductFormDescription")
        @form_description=descriptive.at("./ProductFormDescription").text
      end

      if descriptive.at("./ProductFormDetail")
        @form_detail=ProductFormDetail.from_code(descriptive.at("./ProductFormDetail").text)
      end

      if false
        e_protection_definition={}
        e_protection=nil

        if descriptive.at("./EpubTechnicalProtection")
          e_protection=EpubTechnicalProtection.from_code(descriptive.at("./EpubTechnicalProtection").text)
        end

        descriptive.search("./EpubUsageConstraint").each do |drm|
          definition=nil
          case drm.at("./EpubUsageType").text
            when "01"
              # preview
            when "02"
              # print
              definition= :print
            when "03"
              # copy/paste
              definition= :excerpt
            when "04"
              # share
              definition= :copy
          end

          case drm.at("./EpubUsageStatus").text
            when "01"
              # unlimited
              e_protection_definition[definition]=1001
            when "02"
              # limited
              if drm_limit=drm.at("./EpubUsageLimit")
                e_protection_definition[definition]=drm_limit.at("./Quantity").text.to_i
              else
                e_protection_definition[definition]=0
              end

            when "03"
              # prohibited
              e_protection_definition[definition]=0
          end

        end
      end

      @composition=ProductComposition.from_code(descriptive.at("./ProductComposition").text)

      descriptive.search("./ProductPart").each do |product_part|
        @parts << ProductPart.from_xml(product_part)
      end

    end

    descriptive.search("./Subject").each do |subj|
      @subjects << Subject.from_xml(subj)
    end
  end
end
end