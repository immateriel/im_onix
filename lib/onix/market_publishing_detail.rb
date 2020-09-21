module ONIX
  class MarketPublishingDetail < SubsetDSL
    elements "PublisherRepresentative", :subset, {:klass => "Agent"}
    element "MarketPublishingStatus", :subset
    elements "MarketDate", :subset

    # @!group High level

    # market availability date
    # @return [Date]
    def availability_date
      av = @market_dates.availability.first
      if av
        av.date
      end
    end

    # @!endgroup
  end
end
