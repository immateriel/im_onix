module ONIX
  class CitedContent < SubsetDSL
    element "CitedContentType", :subset, :cardinality => 1
    elements "ContentAudience", :subset, :cardinality => 0..n
    element "Territory", :subset, :cardinality => 0..1
    element "SourceType", :subset, :cardinality => 0..1
    element "ReviewRating", :subset, :cardinality => 0..1
    elements "SourceTitle", :text, :cardinality => 0..n
    elements "ListName", :text, :cardinality => 0..n
    element "PositionOnList", :integer, :cardinality => 0..1
    elements "CitationNote", :text, :cardinality => 0..n
    elements "ResourceLink", :text, :cardinality => 0..n
    elements "ContentDate", :subset, :cardinality => 0..n
  end
end