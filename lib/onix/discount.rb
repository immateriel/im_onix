module ONIX
  class Discount < SubsetDSL
    element "DiscountType", :subset, :cardinality => 0..1
    element "Quantity", :integer, :cardinality => 0..1
    element "ToQuantity", :integer, :cardinality => 0..1
    element "DiscountPercent", :text, :cardinality => 0..1
    element "DiscountAmount", :text, :cardinality => 0..1
  end
end