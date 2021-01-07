module ONIX
  class DiscountCoded < SubsetDSL
    element "DiscountCodeType", :text, :shortcut => :code_type, :cardinality => 1
    element "DiscountCodeTypeName", :text, :shortcut => :code_type_name, :cardinality => 0..1
    element "DiscountCode", :text, :shortcut => :code, :cardinality => 1
  end
end