module ONIX
  class TitleElement < SubsetDSL
    element "SequenceNumber", :integer
    element "TitleElementLevel", :subset, :shortcut => :level
    element "PartNumber", :text
    element "TitleText", :text
    element "TitlePrefix", :text
    element "TitleWithoutPrefix", :text
    element "Subtitle", :text

    scope :product_level, lambda { human_code_match(:title_element_level, /Product/) }
    scope :collection_level, lambda { human_code_match(:title_element_level, /collection/i) }

    # @!group High level
    # flatten title string
    def title
      if @title_text
        @title_text
      else
        if @title_without_prefix
          if @title_prefix
            "#{@title_prefix} #{@title_without_prefix}"
          else
            @title_without_prefix
          end
        end
      end
    end

    # @!endgroup
  end
end