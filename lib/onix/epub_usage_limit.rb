module ONIX
  class EpubUsageLimit < SubsetDSL
    element "EpubUsageUnit", :subset, :shortcut => :unit, :cardinality => 1
    element "Quantity", :integer, :cardinality => 1
  end
end
