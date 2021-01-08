module ONIX
  # product part use full Product to provide file protection and file size
  class ProductPart < SubsetDSL
    include EanMethods
    include ProprietaryIdMethods

    element "PrimaryPart", :bool, :cardinality => 0..1
    elements "ProductIdentifier", :subset, :shortcut => :identifiers, :cardinality => 0..n
    element "ProductForm", :subset, :shortcut => :form, :cardinality => 1
    elements "ProductFormDetail", :subset, :shortcut => :form_details, :cardinality => 0..n
    elements "ProductFormFeature", :subset, :cardinality => 0..n
    # element "ProductPackaging", :subset, :cardinality => 0..1
    elements "ProductFormDescription", :text, :shortcut => :file_description, :cardinality => 0..n
    elements "ProductContentType", :subset, :shortcut => :content_types, :cardinality => 0..n
    elements "Measure", :subset, :cardinality => 0..n
    element "NumberOfItemsOfThisForm", :integer, :cardinality => 0..1
    element "NumberOfCopies", :integer, :cardinality => 0..1
    element "CountryOfManufacture", :subset, :cardinality => 0..1

    def file_formats
      @product_form_details.select { |fd| fd.code =~ /^E1.*/ }
    end

    # full Product if referenced in ONIXMessage
    attr_accessor :product

    # this ProductPart is part of Product
    attr_accessor :part_of

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

    # raw part file description string without HTML
    # @return [String]
    def raw_file_description
      if product_form_description
        Helper.strip_html(product_form_description).gsub(/\s+/, " ").strip
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
        end
      end
    end

    # digital file filesize in bytes
    # @return [Integer]
    def filesize
      if product
        product.filesize
      end
    end

    # @!endgroup
  end
end
