module ONIX
  class Market < SubsetDSL
    element "Territory", :subset, :cardinality => 1
    elements "SalesRestriction", :subset, :cardinality => 0..n
  end
end