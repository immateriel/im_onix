require 'onix/date'
require 'onix/tax'
require 'onix/discount_coded'
require 'onix/discount'
require 'onix/epub_license'
require 'onix/comparison_product_price'

module ONIX
  class Price < SubsetDSL
    # elements "PriceIdentifier", :subset, :cardinality => 0..n


    element "PriceType", :subset, :shortcut => :type, :cardinality => 0..1
    element "PriceQualifier", :subset, :shortcut => :qualifier, :cardinality => 0..1
    elements "EpubTechnicalProtection", :subset, :cardinality => 0..n

    # elements "PriceConstraint", :subset, :cardinality => 0..n


    element "EpubLicense", :subset, :cardinality => 0..1
    element "PriceTypeDescription", :text, :cardinality => 0..n

    # element "PricePer", :subset, :cardinality => 0..1
    # elements "PriceCondition", :subset, :cardinality => 0..n
    # element "MinimumOrderQuantity", :integer, :cardinality => 0..1
    # elements "BatchBonus", :subset, :cardinality => 0..n


    elements "DiscountCoded", :subset, :cardinality => 0..n
    elements "Discount", :subset, :cardinality => 0..n
    element "PriceStatus", :subset
    element "PriceAmount", :float,
            {
              :shortcut => :amount,
              :parse_lambda => lambda { |v| (v * 100).round },
              :serialize_lambda => lambda { |v| format("%.2f", v / 100.0) },
              :cardinality => 0..1
            }
    elements "Tax", :subset, :cardinality => 0..n
    element "TaxExempt", :bool, :cardinality => 0..1
    element "UnpricedItemType", :subset, :cardinality => 0..1
    element "CurrencyCode", :text, :shortcut => :currency, :cardinality => 0..1
    element "Territory", :subset, :cardinality => 0..1
    elements "ComparisonProductPrice", :subset, :cardinality => 0..n
    elements "PriceDate", :subset, :shortcut => :dates, :cardinality => 0..n
    element "PrintedOnProduct", :subset, :cardinality => 0..1
    element "PositionOnProduct", :subset, :cardinality => 0..1

    # FIXME discount_coded != discount
    # @return [DiscountCoded]
    def discount
      self.discount_codeds.first
    end

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
