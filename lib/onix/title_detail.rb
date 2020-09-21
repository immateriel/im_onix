require 'onix/title_element'

module ONIX
  class TitleDetail < SubsetDSL
    element "TitleType", :subset, :shortcut => :type
    elements "TitleElement", :subset
    element "TitleStatement", :text

    scope :distinctive_title, lambda { human_code_match(:title_type, /DistinctiveTitle/) }

    # :category: High level
    # flatten title string
    def title
      return title_statement if title_statement

      title_element = @title_elements.product_level #select { |te| te.level.human=~/Product/ }
      if title_element.size > 0
        title_element.first.title
      end
    end
  end
end
