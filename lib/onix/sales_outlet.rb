module ONIX
  class SalesOutlet < SubsetDSL
    elements "SalesOutletIdentifier", :subset, :shortcut => :identifiers, :cardinality => 0..n
    element "SalesOutletName", :text, :shortcut => :name, :cardinality => 0..1

    # @return [SalesOutletIdentifier]
    def sales_outlet_identifier
      self.sales_outlet_identifiers.first
    end

    # @return [SalesOutletIdentifier]
    def identifier
      self.identifiers.first
    end
  end
end
