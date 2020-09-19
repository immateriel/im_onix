module ONIX
  class RelatedWork < SubsetDSL
    include EanMethods
    element "WorkRelationCode", :subset, :shortcut => :code
    elements "WorkIdentifier", :subset, :shortcut => :identifiers

    # full Product if referenced in ONIXMessage
    def product
      @product
    end

    def product=v
      @product=v
    end
  end
end