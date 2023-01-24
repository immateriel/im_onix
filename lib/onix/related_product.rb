module ONIX
  class RelatedProduct < SubsetDSL
    include IdentifiersMethods::Ean
    include IdentifiersMethods::ProprietaryId

    elements "ProductRelationCode", :subset, :shortcut => :codes, :cardinality => 1..n
    elements "ProductIdentifier", :subset, :shortcut => :identifiers, :cardinality => 1..n
    element "ProductForm", :subset, :shortcut => :form, :cardinality => 0..1
    elements "ProductFormDetail", :subset, :shortcut => :form_details, :cardinality => 0..n

    # full Product if referenced in ONIXMessage
    # @return [Product]
    attr_accessor :product

    # @return [ProductRelationCode]
    def code
      self.codes.first
    end

    # @!group High level
    # @return [String]
    def file_format
      file_formats.first.human if file_formats.first
    end

    # @!endgroup

    # @return [Array<ProductFormDetail>]
    def file_formats
      @product_form_details.select { |fd| fd.code =~ /^E1.*/ }
    end
  end
end
