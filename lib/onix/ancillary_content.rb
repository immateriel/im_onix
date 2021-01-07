module ONIX
  class AncillaryContent < SubsetDSL
    element "AncillaryContentType", :subset, :cardinality => 1
    elements "AncillaryContentDescription", :text, :cardinality => 0..n
    element "Number", :integer, :cardinality => 0..1
  end
end