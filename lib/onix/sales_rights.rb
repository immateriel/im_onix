require 'onix/sales_restriction'
module ONIX
  class SalesRights < SubsetDSL
    element "SalesRightsType", :subset, :shortcut => :type
    element "Territory", :subset
    elements "SalesRestriction", :subset
  end
end
