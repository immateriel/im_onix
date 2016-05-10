require 'onix/sales_restriction'
module ONIX
  class SalesRights < SubsetDSL
    element "SalesRightsType", :subset
    element "Territory", :subset
    elements "SalesRestriction", :subset

    def type
      @sales_rights_type
    end
  end
end
