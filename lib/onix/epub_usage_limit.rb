module ONIX
  class EpubUsageLimit < SubsetDSL
    element "Quantity", :integer, :cardinality => 1
    element "EpubUsageUnit", :subset, :shortcut => :unit, :cardinality => 1
  end
end
