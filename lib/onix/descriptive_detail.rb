require 'onix/identifier'

module ONIX
  class TitleElement < SubsetDSL
    element "TitleElementLevel", :subset, :shortcut => :level
    element "TitleText", :text
    element "TitlePrefix", :text
    element "TitleWithoutPrefix", :text
    element "Subtitle", :text
    element "PartNumber", :integer
    element "SequenceNumber", :integer

    scope :product_level, lambda { human_code_match(:title_element_level, /Product/) }
    scope :collection_level, lambda { human_code_match(:title_element_level, /collection/i) }

    # @!group High level
    # flatten title string
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

    # @!endgroup
  end

  class TitleDetail < SubsetDSL
    element "TitleType", :subset, :shortcut => :type
    elements "TitleElement", :subset
    element "TitleStatement", :text

    scope :distinctive_title, lambda { human_code_match(:title_type, /DistinctiveTitle/) }

    # :category: High level
    # flatten title string
    def title
      return title_statement if title_statement

      title_element = @title_elements.product_level #select { |te| te.level.human=~/Product/ }
      if title_element.size > 0
        title_element.first.title
      else
        nil
      end
    end
  end

  class CollectionSequence < SubsetDSL
    element "CollectionSequenceType", :subset, :shortcut => :type
    element "CollectionSequenceTypeName", :string, :shortcut => :type_name
    element "CollectionSequenceNumber", :string, :shortcut => :number
  end

  class Collection < SubsetDSL
    element "CollectionType", :subset, :shortcut => :type
    elements "CollectionIdentifier", :subset, :shortcut => :identifiers
    elements "TitleDetail", :subset
    elements "CollectionSequence", :subset, :shortcut => :sequences

    scope :publisher, lambda { human_code_match(:collection_type, "PublisherCollection") }

    # @!group High level

    # collection title string
    def title
      if collection_title_element
        collection_title_element.title
      end
    end

    # collection subtitle string
    def subtitle
      if collection_title_element
        collection_title_element.subtitle
      end
    end

    def collection_title_element
      distinctive_title = @title_details.distinctive_title.first
      #select { |td| td.type.human=~/DistinctiveTitle/}.first
      if distinctive_title
        distinctive_title.title_elements.collection_level.first
        #select { |te| te.level.human=~/CollectionLevel/ or te.level.human=~/Subcollection/ }.first
      end
    end

    # @!endgroup

  end

  # product part use full Product to provide file protection and file size
  class ProductPart < SubsetDSL
    include EanMethods
    include ProprietaryIdMethods

    elements "ProductIdentifier", :subset, :shortcut => :identifiers
    element "ProductForm", :subset, :shortcut => :form
    element "ProductFormDescription", :text
    elements "ProductFormDetail", :subset, :shortcut => :form_details
    elements "ProductContentType", :subset, :shortcut => :content_types
    element "NumberOfCopies", :integer

    def file_formats
      @product_form_details.select { |fd| fd.code =~ /^E1.*/ }
    end

    # full Product if referenced in ONIXMessage
    def product
      @product
    end

    def product= v
      @product = v
    end

    # this ProductPart is part of Product
    def part_of
      @part_of
    end

    def part_of= v
      @part_of = v
    end

    # @!group High level

    # digital file format string (Epub,Pdf,AmazonKindle)
    # @return [String]
    def file_format
      file_formats.first.human if file_formats.first
    end

    # digital file format mimetype
    # @return [String]
    def file_mimetype
      if file_formats.first
        file_formats.first.mimetype
      end
    end

    # is digital file reflowable ?
    # @return [Boolean]
    def reflowable?
      return true if @product_form_details.select { |fd| fd.code == "E200" }.length > 0
      return false if @product_form_details.select { |fd| fd.code == "E201" }.length > 0
    end

    # part file description string
    # @return [String]
    def file_description
      @product_form_description
    end

    # raw part file description string without HTML
    # @return [String]
    def raw_file_description
      if @product_form_description
        Helper.strip_html(@product_form_description).gsub(/\s+/, " ").strip
      else
        nil
      end
    end

    # Protection type string (None, Watermarking, DRM, AdobeDRM)
    # @return [String]
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

    # List of protections type string (None, Watermarking, DRM, AdobeDRM)
    # @return [Array<String>]
    def protections
      if product
        product.protections
      else
        if part_of
          part_of.protections
        else
          nil
        end
      end
    end

    # digital file filesize in bytes
    # @return [Integer]
    def filesize
      if product
        product.filesize
      else
        nil
      end
    end

    # @!endgroup
  end

  class Extent < SubsetDSL
    element "ExtentType", :subset, :shortcut => :type
    element "ExtentUnit", :subset, :shortcut => :unit
    element "ExtentValue", :text, :shortcut => :value

    scope :filesize, lambda { human_code_match(:extent_type, /Filesize/) }
    scope :page, lambda { human_code_match(:extent_type, /Page/) }

    # @!group High level

    # bytes count
    # @return [Integer]
    def bytes
      case @extent_unit.human
      when "Bytes"
        @extent_value.to_i
      when "Kbytes"
        (@extent_value.to_f * 1024).to_i
      when "Mbytes"
        (@extent_value.to_f * 1024 * 1024).to_i
      else
        nil
      end
    end

    # pages count
    # @return [Integer]
    def pages
      if @extent_unit.human == "Pages"
        @extent_value.to_i
      else
        nil
      end
    end

    # @!endgroup
  end

  class EpubUsageLimit < SubsetDSL
    element "EpubUsageUnit", :subset, :shortcut => :unit
    element "Quantity", :integer
  end

  class EpubUsageConstraint < SubsetDSL
    element "EpubUsageType", :subset, :shortcut => :type
    element "EpubUsageStatus", :subset, :shortcut => :status
    elements "EpubUsageLimit", :subset, :shortcut => :limits
  end

  class Language < SubsetDSL
    element "LanguageRole", :subset, :shortcut => :role
    element "LanguageCode", :subset, :shortcut => :code

    scope :of_text, lambda { human_code_match(:language_role, "LanguageOfText") }
  end

  class ProductFormFeature < SubsetDSL
    element "ProductFormFeatureType", :subset, :shortcut => :type
    element "ProductFormFeatureValue", :text, :shortcut => :value
    elements "ProductFormFeatureDescription", :text, :shortcut => :descriptions
  end

  class DescriptiveDetail < SubsetDSL
    element "ProductComposition", :subset, :shortcut => :composition
    element "ProductForm", :subset, :shortcut => :form
    elements "ProductFormDetail", :subset, :shortcut => :form_details
    elements "ProductFormFeature", :subset, :shortcut => :form_features
    element "ProductFormDescription", :text, :shortcut => :file_description
    element "PrimaryContentType", :subset, {:klass => "ProductContentType"}
    elements "ProductContentType", :subset, :shortcut => :content_types
    elements "EpubTechnicalProtection", :subset
    elements "EpubUsageConstraint", :subset
    elements "ProductPart", :subset, :shortcut => :parts

    elements "Collection", :subset
    element "NoCollection", :ignore

    elements "TitleDetail", :subset

    elements "Contributor", :subset

    element "EditionType", :subset
    element "EditionNumber", :integer
    element "NoEdition", :ignore

    elements "Language", :subset

    elements "Extent", :subset

    elements "Subject", :subset

    elements "AudienceCode", :subset

    # @!group Shortcuts

    def pages_extent
      @extents.page.first
    end

    def product_title_element
      @title_details.distinctive_title.first.title_elements.product_level.first if @title_details.distinctive_title.first
    end

    def file_formats
      @product_form_details.select { |fd| fd.code =~ /^E1.*/ }
    end

    # @!endgroup

    # @!group High level

    # product title string
    # @return [String]
    def title
      product_title_element.title if product_title_element
    end

    # product subtitle string
    # @return [String]
    def subtitle
      product_title_element.subtitle if product_title_element
    end

    def pages
      if pages_extent
        pages_extent.pages
      else
        nil
      end
    end

    def filesize_extent
      @extents.filesize.first
    end

    # file size in bytes
    # @return [Integer]
    def filesize
      if filesize_extent
        filesize_extent.bytes
      else
        nil
      end
    end

    # is digital ?
    # @return [Boolean]
    def digital?
      if @product_form and @product_form.human =~ /Digital/
        true
      else
        false
      end
    end

    # is digital offer streaming ?
    def streaming?
      @product_form.code == "EC"
    end

    def audio?
      not audio_formats.empty?
    end

    def audio_format
      self.audio_formats.first.human if self.audio_formats.first
    end

    def audio_formats
      @product_form_details.select { |fd| fd.code =~ /^A.*/ }
    end

    # is digital offer a bundle ?
    def bundle?
      @product_composition.human == "MultipleitemRetailProduct"
    end

    # digital file format string (Epub,Pdf,AmazonKindle)
    def file_format
      file_formats.first.human if file_formats.first
    end

    # digital file format mimetype
    def file_mimetype
      if file_formats.first
        file_formats.first.mimetype
      end
    end

    # is digital file reflowable ?
    # @return [Boolean]
    def reflowable?
      return true if @product_form_details.select { |fd| fd.code == "E200" }.length > 0
      return false if @product_form_details.select { |fd| fd.code == "E201" }.length > 0
    end

    # @return [String]
    def protection_type
      if @epub_technical_protections.length > 0
        if @epub_technical_protections.length == 1
          @epub_technical_protections.first.human
        else
          raise ExpectsOneButHasSeveral, @epub_technical_protections.map(&:human)
        end
      end
    end

    # @return [Array<String>]
    def protections
      return nil if @epub_technical_protections.length == 0
      @epub_technical_protections.map(&:human)
    end

    # @return [String]
    def language_of_text
      l = @languages.of_text.first
      if l
        l.code
      else
        nil
      end
    end

    def publisher_collection
      @collections.publisher.first
    end

    def publisher_collection_title
      if self.publisher_collection
        self.publisher_collection.title
      end
    end

    def bisac_categories
      @subjects.bisac
    end

    def clil_categories
      @subjects.clil
    end

    def keywords
      kws = @subjects.keyword.map { |kw| kw.heading_text }.compact
      kws = kws.flat_map { |kw| kw.split(/;|,|\n/) }.map { |kw| kw.strip }
      kws.reject! { |k| k == "" }
      kws
    end

    # @!endgroup
  end
end
