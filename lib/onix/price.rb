require 'onix/tax'
require 'onix/discount_coded'
require 'onix/date'

module ONIX
  class Price < SubsetDSL
    element "PriceType", :subset, :shortcut => :type
    element "PriceQualifier", :subset, :shortcut => :qualifier
    element "DiscountCoded", :subset, :shortcut => :discount
    element "PriceStatus", :subset
    elements "PriceDate", :subset, :shortcut => :dates
    element "PriceAmount", :float,
            {
                :shortcut => :amount,
                :parse_lambda => lambda { |v| (v * 100).round },
                :serialize_lambda => lambda { |v| v / 100.0 }
            }
    element "Tax", :subset
    element "CurrencyCode", :text, :shortcut => :currency
    element "Territory", :subset

    # @!group High level

    # price from date
    # @return [Date]
    def from_date
      dt = @price_dates.from_date.first
      if dt
        dt.date
      end
    end

    # price until date
    # @return [Date]
    def until_date
      dt = @price_dates.until_date.first
      if dt
        dt.date
      end
    end

    # does the price include taxes ?
    # @return [Boolean]
    def including_tax?
      if self.type.human =~ /IncludingTax/
        true
      else
        false
      end
    end

    # @!endgroup
  end
end
