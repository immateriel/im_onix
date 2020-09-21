require 'onix/date'
require 'onix/market'
require 'onix/market_publishing_detail'
require 'onix/supply_detail'

module ONIX
  class ProductSupply < SubsetDSL
    elements "Market", :subset
    element "MarketPublishingDetail", :subset
    elements "SupplyDetail", :subset

    # availability date from market
    # @return [Date]
    def availability_date
      if @market_publishing_detail
        @market_publishing_detail.availability_date
      end
    end

    # countries string array
    # @return [Array<String>]
    def countries
      @markets.map { |market| market.territory.countries }.flatten.uniq
    end

    # distributors string array
    # @return [Array<String>]
    def distributors
      @supply_details.map { |supply_detail| supply_detail.distributors }.flatten.uniq { |distributor| distributor.name }
    end

    # available supply details
    # @return [Array<SupplyDetail>]
    def available_supply_details
      @supply_details.select { |supply_detail| supply_detail.available? }
    end

    # unavailable supply details
    # @return [Array<SupplyDetail>]
    def unavailable_supply_details
      @supply_details.delete_if { |supply_detail| supply_detail.available? }
    end

    def available?
      self.available_supply_details.length > 0
    end
  end
end
