require 'onix/tax'
require 'onix/discount_coded'
require 'onix/date'

module ONIX
  class Price < SubsetDSL
    element "PriceType", :subset, :shortcut => :type, :cardinality => 0..1
    element "PriceQualifier", :subset, :shortcut => :qualifier, :cardinality => 0..1
    element "PriceTypeDescription", :text, :cardinality => 0..n
    element "DiscountCoded", :subset, :shortcut => :discount, :cardinality => 0..n
    element "PriceStatus", :subset
    elements "PriceDate", :subset, :shortcut => :dates
    element "PriceAmount", :float,
            {
                :shortcut => :amount,
                :parse_lambda => lambda { |v| (v * 100).round },
                :serialize_lambda => lambda { |v| v / 100.0 },
                :cardinality => 0..1
            }
    element "Tax", :subset, :cardinality => 0..n
    element "CurrencyCode", :text, :shortcut => :currency, :cardinality => 0..1
    element "Territory", :subset, :cardinality => 0..1

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
