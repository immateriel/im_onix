module ONIX
  class Measure < SubsetDSL
    element "MeasureType", :subset, :cardinality => 1
    element "Measurement", :text, :cardinality => 1
    element "MeasureUnitCode", :subset, :cardinality => 1
  end
end