require 'onix/identifier'

module ONIX
  class ProductContact < SubsetDSL
    element "ProductContactRole", :subset, :cardinality => 1
    elements "ProductContactIdentifier", :subset, :cardinality => 0..n
    element "ProductContactName", :text, :cardinality => 0..1
    element "ContactName", :text, :cardinality => 0..1
    element "EmailAddress", :text, :cardinality => 0..1
  end
end