module ONIX
  class RelatedProduct < SubsetDSL
    include EanMethods
    include ProprietaryIdMethods

    element "ProductRelationCode", :subset, :shortcut => :code
    elements "ProductIdentifier", :subset, :shortcut => :identifiers
    element "ProductForm", :subset, :shortcut => :form
    elements "ProductFormDetail", :subset, :shortcut => :form_details

    # full Product if referenced in ONIXMessage
    def product
      @product
    end

    def product= v
      @product = v
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
