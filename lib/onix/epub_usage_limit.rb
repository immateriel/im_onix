module ONIX
  class EpubUsageLimit < SubsetDSL
    element "EpubUsageUnit", :subset, :shortcut => :unit
    element "Quantity", :integer
  end
end
