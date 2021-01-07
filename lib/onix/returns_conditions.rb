module ONIX
  class ReturnsConditions < SubsetDSL
    element "ReturnsCodeType", :subset, :cardinality => 1
    element "ReturnsCodeTypeName", :text, :cardinality => 0..1
    element "ReturnsCode", :subset, :cardinality => 1
    elements "ReturnsNote", :text, :cardinality => 0..n
  end
end