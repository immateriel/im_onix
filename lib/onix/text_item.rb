require 'onix/code'
require 'onix/identifier'
require 'onix/page_run'

module ONIX
  class TextItem < SubsetDSL
    element "TextItemType", :subset, :cardinality => 1
    elements "TextItemIdentifier", :subset, :cardinality => 0..n
    elements "PageRun", :subset, :cardinality => 0..n
    element "NumberOfPages", :integer, :cardinality => 0..1
  end
end