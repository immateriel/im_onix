module ONIX
  class EpubUsageConstraint < SubsetDSL
    element "EpubUsageType", :subset, :shortcut => :type
    element "EpubUsageStatus", :subset, :shortcut => :status
    elements "EpubUsageLimit", :subset, :shortcut => :limits
  end
end
