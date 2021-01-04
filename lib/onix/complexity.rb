module ONIX
  class Complexity < SubsetDSL
    element "ComplexitySchemeIdentifier", :subset, :cardinality => 1
    element "ComplexityCode", :text, :cardinality => 1
  end
end