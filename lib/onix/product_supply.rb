require 'onix/price'
require 'onix/date'

module ONIX

  class Market < SubsetDSL
    element "Territory", :subset
    elements "SalesRestriction", :subset
  end

  class MarketPublishingDetail < SubsetDSL
    elements "PublisherRepresentative", :subset, {:klass=>"Agent"}
    element "MarketPublishingStatus", :subset
    elements "MarketDate", :subset

    def availability_date
      av=@market_dates.availability.first
      if av
        av.date
      else
        nil
      end
    end
  end

  class SupplyDetail < SubsetDSL
    elements "Supplier", :subset
    element "ProductAvailability", :subset
    elements "SupplyDate", :subset
    elements "Price", :subset
    element "UnpricedItemType", :subset

    def availability
      @product_availability
    end

    def distributors
      @suppliers.select{|s| s.role.human=~/Distributor/}.uniq
    end

    def available?
      ["Available","NotYetAvailable","InStock","ToOrder","Pod"].include?(@product_availability.human)
    end

    def sold_separately?
      @product_availability.human!="NotSoldSeparately"
    end

    def availability_date
      av=@supply_dates.availability.first
      if av
        av.date
      else
        nil
      end
    end
  end

  class ProductSupply < SubsetDSL
    elements "Market", :subset
    element "MarketPublishingDetail", :subset
    elements "SupplyDetail", :subset

    def availability_date
      if @market_publishing_detail
        @market_publishing_detail.availability_date
      end
    end

    def countries
      @markets.map{|m| m.territory.countries}.flatten.uniq
    end

    def distributors
      @supply_details.map{|sd| sd.distributors}.flatten.uniq{|d| d.name}
    end

    def available_supply_details
      @supply_details.select{|sd| sd.available?}
    end

    def unavailable_supply_details
      @supply_details.delete_if{|sd| sd.available?}
    end

    def available?
      self.available_supply_details.length > 0
    end
  end
end
