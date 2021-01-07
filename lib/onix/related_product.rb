module ONIX
  class RelatedProduct < SubsetDSL
    include EanMethods
    include ProprietaryIdMethods

    elements "ProductRelationCode", :subset, :shortcut => :codes, :cardinality => 1..n
    elements "ProductIdentifier", :subset, :shortcut => :identifiers, :cardinality => 1..n
    element "ProductForm", :subset, :shortcut => :form, :cardinality => 0..1
    elements "ProductFormDetail", :subset, :shortcut => :form_details, :cardinality => 0..n

    # full Product if referenced in ONIXMessage
    attr_accessor :product

    def code
      self.codes.first
    end

    # @!group High level
    def file_format
      file_formats.first.human if file_formats.first
    end

    # @!endgroup

    def file_formats
      @product_form_details.select { |fd| fd.code =~ /^E1.*/ }
    end
  end
end
