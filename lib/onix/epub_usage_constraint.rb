module ONIX
  class EpubUsageConstraint < SubsetDSL
    element "EpubUsageType", :subset, :shortcut => :type, :cardinality => 1
    element "EpubUsageStatus", :subset, :shortcut => :status, :cardinality => 1
    elements "EpubUsageLimit", :subset, :shortcut => :limits, :cardinality => 0..n
  end
end
