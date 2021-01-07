module ONIX
  class PageRun < SubsetDSL
    element "FirstPageNumber", :text, :cardinality => 1
    element "LastPageNumber", :text, :cardinality => 0..1
  end
end