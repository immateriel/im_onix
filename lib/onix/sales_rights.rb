require 'onix/sales_restriction'

module ONIX
  class SalesRights < SubsetDSL
    element "SalesRightsType", :subset, :shortcut => :type, :cardinality => 1
    element "Territory", :subset, :cardinality => 1
    elements "SalesRestriction", :subset, :cardinality => 0..n
    elements "ProductIdentifier", :subset, :cardinality => 0..n
    element "PublisherName", :text, :cardinality => 0..1
  end
end
