module ONIX
  class ProductFormFeature < SubsetDSL
    element "ProductFormFeatureType", :subset, :shortcut => :type
    element "ProductFormFeatureValue", :text, :shortcut => :value
    elements "ProductFormFeatureDescription", :text, :shortcut => :descriptions
  end
end
