module ONIX
  class ResourceFeature < SubsetDSL
    element "ResourceFeatureType", :subset, :shortcut => :type, :cardinality => 1
    element "FeatureValue", :text, :shortcut => :value, :cardinality => 0..1
    elements "FeatureNote", :text, :shortcut => :notes, :cardinality => 0..n

    scope :caption, lambda { human_code_match(:resource_feature_type, "Caption") }
  end
end