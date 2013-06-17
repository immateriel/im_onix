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
      @identifiers=Identifier.parse_identifiers(col, "Collection")

      col.search("./TitleDetail").each do |title_detail|
        @title_details << TitleDetail.from_xml(title_detail)
      end
    end
  end

  class ProductPart < Subset
    attr_accessor :identifiers, :form, :form_detail, :form_description,
                  :product


    include EanMethods


    def file_format
      if @form_detail
        @form_detail.human
      else
        "Undefined"
      end
    end

    def file_description
      @form_description
    end

    def raw_file_description
      if @form_description
        @form_description.gsub(/\s+/," ").strip
      else
        nil
      end
    end

    def parse(ppart)
      @identifiers=Identifier.parse_identifiers(ppart, "Product")

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

  class Extent < Subset
    attr_accessor :type, :value, :unit

    def bytes
      case @unit.human
        when "Bytes"
          @value.to_i
        when "Kbytes"
          (@value.to_f*1024).to_i
        when "Mbytes"
          (@value.to_f*1024*1024).to_i
        else
          nil
      end
    end

    def pages
      if @unit.human=="Pages"
        @value.to_i
      else
        nil
      end
    end

    def parse(e)
      @type=ExtentType.from_code(e.at("./ExtentType").text)
      @unit=ExtentUnit.from_code(e.at("./ExtentUnit").text)
      @value=Helper.text_at(e, "./ExtentValue")
    end

  end

  class EpubUsageLimit < Subset
    attr_accessor :quantity, :unit

    def parse(eul)
      @unit=EpubUsageUnit.from_code(eul.at("./EpubUsageUnit").text)
      @quantity=eul.at("./Quantity").text.to_i
    end
  end

  class EpubUsageConstraint < Subset
    attr_accessor :type, :status, :limits

    def initialize
      @limits=[]
    end

    def parse(drm)
      @type=EpubUsageType.from_code(drm.at("./EpubUsageType").text)
      @status=EpubUsageStatus.from_code(drm.at("./EpubUsageStatus").text)
      drm.search("./EpubUsageLimit").each do |l|
        @limits << EpubUsageLimit.from_xml(l)
      end
    end
  end

  class DescriptiveDetail < Subset
    attr_accessor :title_details, :collection, :language,
                  :composition,
                  :form, :form_detail, :form_description, :parts,
                  :contributors,
                  :subjects,
                  :collections,
                  :extents,
                  :epub_technical_protections

    def initialize
      @title_details=[]
      @text_contents=[]
      @parts=[]
      @contributors=[]
      @subjects=[]
      @collections=[]
      @extents=[]
      @epub_technical_protections=[]
      @epub_usage_constraints=[]

    end

    def title
      @title_details.select { |td| td.type.human=~/DistinctiveTitle/ }.first.title_elements.first.title
    end

    def subtitle
      @title_details.select { |td| td.type.human=~/DistinctiveTitle/ }.first.title_elements.first.subtitle
    end

    def pages_extent
      @extents.select{|e| e.type.human=~/PageCount/ || e.type.human=~/NumberOfPage/}.first
    end

    def pages
      if pages_extent
        pages_extent.pages
      else
        nil
      end
    end

    def filesize_extent
      @extents.select{|e| e.type.human=="Filesize"}.first
    end

    def filesize
      if filesize_extent
        filesize_extent.bytes
      else
        nil
      end
    end

    def digital?
      if @form.human=~/Digital/
        true
      else
        false
      end
    end

    def bundle?
      @composition.human=="MultipleitemRetailProduct"
    end

    def file_format
      if @form_detail
        @form_detail.human
      else
        "Undefined"
      end
    end

    def file_description
      @form_description
    end

    def protection_type
      if @epub_technical_protections.length > 0
        if @epub_technical_protections.length == 1
          @epub_technical_protections.first.human
        else
          raise ExpectsOneButHasSeveral, @epub_technical_protections.map(&:type)
        end
      else
        "Undefined"
      end
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

      descriptive.search("./Extent").each do |e|
        @extents << Extent.from_xml(e)
      end

      # TODO
      if descriptive.at("./Language/LanguageCode")
        @language=descriptive.at("./Language/LanguageCode").text
      end

      if descriptive.at("./ProductComposition")
        if descriptive.at("./ProductForm")
          @form=ProductForm.from_code(descriptive.at("./ProductForm").text)
        end

        if descriptive.at("./ProductFormDescription")
          @form_description=descriptive.at("./ProductFormDescription").text
        end

        if descriptive.at("./ProductFormDetail")
          @form_detail=ProductFormDetail.from_code(descriptive.at("./ProductFormDetail").text)
        end

          if descriptive.search("./EpubTechnicalProtection").each do |etp|
            @epub_technical_protections << EpubTechnicalProtection.from_code(etp.text)
          end

            descriptive.search("./EpubUsageConstraint").each do |euc|
              @epub_usage_constraints << EpubUsageConstraint.from_xml(euc)
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