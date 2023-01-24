module ONIX
  class ProductClassification < SubsetDSL
    element "ProductClassificationType", :subset, :cardinality => 1
    element "ProductClassificationTypeName", :text, :cardinality => 0..1
    element "ProductClassificationCode", :text, :cardinality => 1
    element "Percent", :text, :cardinality => 0..1
  end
end