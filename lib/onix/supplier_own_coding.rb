module ONIX
  class SupplierOwnCoding < SubsetDSL
    element "SupplierCodeType", :subset, :cardinality => 1
    element "SupplierCodeTypeName", :text, :cardinality => 0..1
    element "SupplierCodeValue", :text, :cardinality => 1
  end
end