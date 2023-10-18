require 'onix/collection'
require 'onix/epub_usage_constraint'
require 'onix/epub_license'
require 'onix/extent'
require 'onix/language'
require 'onix/ancillary_content'
require 'onix/product_form_feature'
require 'onix/product_classification'
require 'onix/product_part'
require 'onix/title_detail'
require 'onix/contributor'
require 'onix/measure'
require 'onix/subject'
require 'onix/audience'
require 'onix/audience_range'
require 'onix/complexity'

module ONIX
  class DescriptiveDetail < SubsetDSL
    element "ProductComposition", :subset, :shortcut => :composition, :cardinality => 1
    element "ProductForm", :subset, :shortcut => :form, :cardinality => 1
    elements "ProductFormDetail", :subset, :shortcut => :form_details, :cardinality => 0..n
    elements "ProductFormFeature", :subset, :shortcut => :form_features, :cardinality => 0..n
    element "ProductPackaging", :subset, :cardinality => 0..1
    element "ProductFormDescription", :text, :shortcut => :file_description, :cardinality => 0..n
    element "TradeCategory", :subset, :cardinality => 0..1
    element "PrimaryContentType", :subset, :klass => "ProductContentType"
    elements "ProductContentType", :subset, :shortcut => :content_types, :cardinality => 0..n
    elements "Measure", :subset, :cardinality => 0..n
    element "CountryOfManufacture", :subset, :klass=>"CountryCode", :cardinality => 0..1
    elements "EpubTechnicalProtection", :subset, :cardinality => 0..n
    elements "EpubUsageConstraint", :subset, :cardinality => 0..n
    element "EpubLicense", :subset, :cardinality => 0..1
    elements "MapScale", :integer, :cardinality => 0..n
    elements "ProductClassification", :subset, :cardinality => 0..n
    elements "ProductPart", :subset, :shortcut => :parts, :cardinality => 0..n
    elements "Collection", :subset, :cardinality => 0..n
    element "NoCollection", :bool, :cardinality => 0..1
    elements "TitleDetail", :subset, :cardinality => 0..n
    element "ThesisType", :subset, :cardinality => 0..1
    element "ThesisPresentedTo", :text, :cardinality => 0..1
    element "ThesisYear", :text, :cardinality => 0..1
    elements "Contributor", :subset, :cardinality => 0..n
    elements "ContributorStatement", :text, :cardinality => 0..n
    element "NoContributor", :bool, :cardinality => 0..1

    # elements "Conference", :subset, :cardinality => 0..n
    # elements "Event", :subset, :cardinality => 0..n


    element "EditionType", :subset, :cardinality => 0..n
    element "EditionNumber", :integer, :cardinality => 0..1
    element "EditionVersionNumber", :text, :cardinality => 0..1
    elements "EditionStatement", :text, :cardinality => 0..n
    element "NoEdition", :bool, :cardinality => 0..1

    # element "ReligiousText", :subset, :cardinality => 0..1


    elements "Language", :subset, :cardinality => 0..n
    elements "Extent", :subset, :cardinality => 0..n
    element "Illustrated", :subset, :cardinality => 0..1
    element "NumberOfIllustrations", :integer, :cardinality => 0..1
    elements "IllustrationsNote", :text, :cardinality => 0..n
    elements "AncillaryContent", :subset, :cardinality => 0..n
    elements "Subject", :subset, :cardinality => 0..n

    # elements "NameAsSubject", :subset, :cardinality => 0..n


    elements "AudienceCode", :subset, :cardinality => 0..n
    elements "Audience", :subset, :cardinality => 0..n
    elements "AudienceRange", :subset, :cardinality => 0..n
    elements "AudienceDescription", :text, :cardinality => 0..n
    elements "Complexity", :subset, :cardinality => 0..n

    # @!group Shortcuts

    # @return [Extent]
    def pages_extent
      @extents.page.first
    end

    # @return [TitleElement]
    def product_title_element
      @title_details.distinctive_title.first.title_elements.product_level.first if @title_details.distinctive_title.first
    end

    # @return [Array<ProductFormDetail>]
    def file_formats
      @product_form_details.select { |fd| fd.code =~ /^E1.*/ }
    end

    # @return [Collection]
    def publisher_collection
      @collections.publisher.first
    end

    # @return [Extent]
    def filesize_extent
      @extents.filesize.first
    end

    # @return [Array<ProductFormDetail>]
    def audio_formats
      @product_form_details.select { |fd| fd.code =~ /^A.*/ }
    end

    # BISAC categories
    # @return [Array<Subject>]
    def bisac_categories
      @subjects.bisac
    end

    # CLIL categories
    # @return [Array<Subject>]
    def clil_categories
      @subjects.clil
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

    # page count
    # @return [Integer]
    def pages
      if pages_extent
        pages_extent.pages
      end
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

    # digital offer has DRM ?
    # @return [Boolean]
    def drmized?
      @protections.any? { |p| p =~ /Drm/ }
    end

    # is digital offer streaming ?
    # @return [Boolean]
    def streaming?
      @product_form.code == "EC"
    end

    # is digital offer audio ?
    # @return [Boolean]
    def audio?
      not audio_formats.empty?
    end

    # @return [String]
    def audio_format
      self.audio_formats.first.human if self.audio_formats.first
    end

    # is digital offer a bundle ?
    # @return [Boolean]
    def bundle?
      @product_composition.human == "MultipleComponentRetailProduct"
    end

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

    # protection type string
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

    # protections string array
    # @return [Array<String>]
    def protections
      return [] if @epub_technical_protections.length == 0
      @epub_technical_protections.map(&:human)
    end

    # language of text
    # @return [String]
    def language_of_text
      @languages.of_text.first&.code
    end

    # language of the original text (only for translated texts)
    # @return [String]
    def language_of_original_text
      @languages.of_original_text.first&.code
    end

    # publisher collection title
    # @return [String]
    def publisher_collection_title
      if self.publisher_collection
        self.publisher_collection.title
      end
    end

    # BISAC categories identifiers string array (eg: FIC000000)
    # @return [Array<String>]
    def bisac_categories_codes
      self.bisac_categories.map { |c| c.code }.uniq
    end

    # CLIL categories identifier string array
    # @return [Array<String>]
    def clil_categories_codes
      self.clil_categories.map { |c| c.code }.uniq
    end

    # keywords string array
    # @return [Array<String>]
    def keywords
      kws = @subjects.keyword.map { |kw| kw.heading_text }.compact
      kws = kws.flat_map { |kw| kw.split(/;|,|\n/) }.map { |kw| kw.strip }
      kws.reject! { |k| k == "" }
      kws
    end

    # @!endgroup
  end
end
