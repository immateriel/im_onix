require 'onix/content_item'

module ONIX
  class ContentDetail < SubsetDSL
    elements "ContentItem", :subset, :cardinality => 0..n
  end
end
