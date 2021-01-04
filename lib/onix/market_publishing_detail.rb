require 'onix/product_contact'

module ONIX
  class MarketPublishingDetail < SubsetDSL
    elements "PublisherRepresentative", :subset, :klass => "Agent", :cardinality => 0..n
    elements "ProductContact", :subset, :cardinality => 0..n
    element "MarketPublishingStatus", :subset, :cardinality => 1
    elements "MarketPublishingStatusNote", :text, :cardinality => 0..n
    elements "MarketDate", :subset, :cardinality => 0..n
    elements "PromotionCampaign", :text, :cardinality => 0..n
    element "PromotionContact", :text, :cardinality => 0..1
    elements "InitialPrintRun", :text, :cardinality => 0..n
    elements "ReprintDetail", :text, :cardinality => 0..n
    elements "CopiesSold", :text, :cardinality => 0..n
    elements "BookClubAdoption", :text, :cardinality => 0..n

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
