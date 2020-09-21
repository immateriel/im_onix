module ONIX
  class DiscountCoded < SubsetDSL
    element "DiscountCodeType", :text, :shortcut => :code_type
    element "DiscountCodeTypeName", :text, :shortcut => :code_type_name
    element "DiscountCode", :text, :shortcut => :code
  end
end