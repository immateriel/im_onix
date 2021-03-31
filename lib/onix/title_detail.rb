require 'onix/title_element'

module ONIX
  class TitleDetail < SubsetDSL
    element "TitleType", :subset, :shortcut => :type, :cardinality => 1
    elements "TitleElement", :subset, :cardinality => 1..n
    element "TitleStatement", :text, :cardinality => 0..1

    scope :distinctive_title, lambda { human_code_match(:title_type, /DistinctiveTitle/) }

    # :category: High level
    # flatten title string
    # @return [String]
    def title
      return title_statement if title_statement

      title_element = @title_elements.product_level #select { |te| te.level.human=~/Product/ }
      if title_element.size > 0
        title_element.first.title
      end
    end
  end
end
