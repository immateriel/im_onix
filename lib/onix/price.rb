require 'onix/tax'
require 'onix/discount_coded'
require 'onix/date'

module ONIX
  class Price < SubsetDSL
    element "PriceType", :subset
    element "PriceQualifier", :subset
    element "DiscountCoded", :subset
    element "PriceStatus", :subset
    elements "PriceDate", :subset
    element "PriceAmount", :float,
            {
                :parse_lambda => lambda { |v| (v*100).round },
                :serialize_lambda => lambda {|v| v/100.0}
            }
    element "Tax", :subset
    element "CurrencyCode", :text
    element "Territory", :subset

    # shortcuts
    def dates
      @price_dates
    end

    def amount
      @price_amount
    end

    def type
      @price_type
    end

    def currency
      @currency_code
    end

    def qualifier
      @price_qualifier
    end

    def discount
      @discount_coded
    end

    def from_date
      dt=@price_dates.from.first
      if dt
        dt.date
      else
        nil
      end
    end

    def until_date
      dt=@price_dates.until.first
      if dt
        dt.date
      else
        nil
      end
    end

    def including_tax?
      if self.type.human=~/IncludingTax/
        true
      else
        false
      end
    end

  end

end
