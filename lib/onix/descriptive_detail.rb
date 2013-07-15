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

    def title
      @title_details.select { |td| td.type.human=~/DistinctiveTitle/ }.first.title_elements.first.title
    end

    def subtitle
      @title_details.select { |td| td.type.human=~/DistinctiveTitle/ }.first.title_elements.first.subtitle
    end


    def parse(col)
      @type=CollectionType.from_code(col.at("./CollectionType").text)
      @identifiers=Identifier.parse_identifiers(col, "Collection")

      col.search("./TitleDetail").each do |title_detail|
        @title_details << TitleDetail.from_xml(title_detail)
      end
    end
  end

  class ProductPart < Subset
    attr_accessor :identifiers, :form, :form_details, :form_description,
                  :product, :part_of


    include EanMethods

    def initialize
      @form_details = []
    end

    def file_format
      if self.file_formats.first
        self.file_formats.first.human
      else
        "Undefined"
      end
    end

    def file_formats
      @form_details.select{|fd| fd.code =~ /^E1.*/}
    end

    def file_description
      @form_description
    end

    def raw_file_description
      if @form_description
        Helper.strip_html(@form_description).gsub(/\s+/," ").strip
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

      ppart.search("./ProductFormDetail").each do |d|
        @form_details << ProductFormDetail.from_code(d.text)
      end

    end

    def protection_type
      if product
        product.protection_type
      else
        if part_of
          part_of.protection_type
        else
          nil
        end
      end
    end

    def filesize
      if product
        product.filesize
      else
        nil
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

  class Language < Subset
    attr_accessor :role, :code
    def parse(l)
      @role=LanguageRole.from_code(l.at("./LanguageRole").text)
      @code=LanguageCode.from_code(l.at("./LanguageCode").text)
    end
  end

  class ProductFormFeature < Subset
    attr_accessor :type, :value, :descriptions

    def initialize
      @descriptions=[]
    end

    def parse(pff)
      if pff.at("./ProductFormFeatureType")
        @type=ProductFormFeatureType.from_code(pff.at("./ProductFormFeatureType").text)
      end

      if pff.at("./ProductFormFeatureValue")
        @value=pff.at("./ProductFormFeatureValue").text
      end

      pff.search("./ProductFormFeatureDescription").each do |pfd|
        @descriptions << pfd.text
      end

    end

  end
  class DescriptiveDetail < Subset
    attr_accessor :title_details, :collection,
                  :languages,
                  :composition,
                  :form, :form_details, :form_features, :form_description, :parts,
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
      @languages=[]
      @form_details=[]
      @form_features=[]

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
      if self.file_formats.first
        self.file_formats.first.human
      else
        "Undefined"
      end
    end

    def file_formats
      @form_details.select{|fd| fd.code =~ /^E1.*/}
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

    def language_of_text
      l=@languages.select{|l| l.role.human=="LanguageOfText"}.first
      if l
        l.code
      else
        nil
      end
    end

    def publisher_collection
      @collections.select{|c| c.type.human=="PublisherCollection"}.first
    end

    def publisher_collection_title
      if self.publisher_collection
        self.publisher_collection.title
      end

    end

    def bisac_categories
      @subjects.select{|s| s.scheme_identifier.human=="BisacSubjectHeading"}
    end

    def clil_categories
      @subjects.select{|s| s.scheme_identifier.human=="Clil"}
    end

    def keywords
      kws=@subjects.select{|s| s.scheme_identifier.human=="Keywords"}.map{|kw| kw.heading_text}
      kws.map{|kw| kw.split(/;|,|\n/)}.flatten.map{|kw| kw.strip}
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

      descriptive.search("./Language").each do |l|
        @languages << Language.from_xml(l)
      end

      if descriptive.at("./ProductComposition")
        if descriptive.at("./ProductForm")
          @form=ProductForm.from_code(descriptive.at("./ProductForm").text)
        end

        descriptive.search("./ProductFormFeature").each do |pff|
          @form_features << ProductFormFeature.from_xml(pff)
        end

        if descriptive.at("./ProductFormDescription")
          @form_description=descriptive.at("./ProductFormDescription").text
        end

        descriptive.search("./ProductFormDetail").each do |d|
          @form_details << ProductFormDetail.from_code(d.text)
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
            part=ProductPart.from_xml(product_part)
            part.part_of=self
            @parts << part
          end

        end

        descriptive.search("./Subject").each do |subj|
          @subjects << Subject.from_xml(subj)
        end
      end
    end
  end