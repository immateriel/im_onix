module ONIX
  class Audience < SubsetDSL
    element "AudienceCodeType", :subset, :cardinality => 1
    element "AudienceCodeTypeName", :text, :cardinality => 0..1
    element "AudienceCodeValue", :text, :cardinality => 1
  end
end