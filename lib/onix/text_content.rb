module ONIX
  class TextContent < SubsetDSL
    element "TextType", :subset, :shortcut => :type, :cardinality => 1
    element "ContentAudience", :subset, :cardinality => 1..n
    element "Text", :text, :cardinality => 1..n
    element "TextAuthor", :text, :cardinality => 0..n
    element "TextSourceCorporate", :text, :cardinality => 0..1
    element "SourceTitle", :text, :cardinality => 0..n

    scope :description, lambda { human_code_match(:text_type, "Description") }
    scope :short_description, lambda { human_code_match(:text_type, "ShortDescriptionannotation") }
  end
end
