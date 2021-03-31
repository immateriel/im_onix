module ONIX
  class TitleElement < SubsetDSL
    element "SequenceNumber", :integer, :cardinality => 0..1
    element "TitleElementLevel", :subset, :shortcut => :level, :cardinality => 1
    element "PartNumber", :text, :cardinality => 0..1
    element "YearOfAnnual", :text, :cardinality => 0..1
    element "TitleText", :text, :cardinality => 0..1
    element "TitlePrefix", :text, :cardinality => 0..1
    element "NoPrefix", :bool, :cardinality => 0..1
    element "TitleWithoutPrefix", :text, :cardinality => 0..1
    element "Subtitle", :text, :cardinality => 0..1

    scope :product_level, lambda { human_code_match(:title_element_level, /Product/) }
    scope :collection_level, lambda { human_code_match(:title_element_level, /collection/i) }

    # @!group High level
    # flatten title string
    # @return [String]
    def title
      if title_text
        title_text
      else
        if title_without_prefix
          if title_prefix
            "#{title_prefix} #{title_without_prefix}"
          else
            title_without_prefix
          end
        end
      end
    end

    # @!endgroup
  end
end