module ONIX
  class SalesOutlet < SubsetDSL
    elements "SalesOutletIdentifier", :subset, :shortcut => :identifier, :cardinality => 0..n
    element "SalesOutletName", :text, :shortcut => :name, :cardinality => 0..1
  end

  def sales_outlet_identifier
    self.sales_outlet_identifiers.first
  end
end
