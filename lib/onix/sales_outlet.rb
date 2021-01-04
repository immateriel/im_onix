module ONIX
  class SalesOutlet < SubsetDSL
    element "SalesOutletIdentifier", :subset, :shortcut => :identifier, :cardinality => 0..n
    element "SalesOutletName", :text, :shortcut => :name, :cardinality => 0..1
  end
end
