module ONIX
  class SalesOutlet < SubsetDSL
    element "SalesOutletIdentifier", :subset
    element "SalesOutletName", :text

    def identifier
      @sales_outlet_identifier
    end

    def name
      @sales_outlet_name
    end
  end
end
