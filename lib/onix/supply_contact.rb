module ONIX
  class SupplyContact < SubsetDSL
    element "SupplyContactRole", :subset, :cardinality => 1
    elements "SupplyContactIdentifier", :subset, :cardinality => 0..n
    element "SupplyContactName", :text, :cardinality => 0..1
    element "ContactName", :text, :cardinality => 0..1
    element "EmailAddress", :text, :cardinality => 0..1
  end
end