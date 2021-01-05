require 'onix/code'
require 'onix/identifier'

module ONIX
  class ComparisonProductPrice < SubsetDSL
    elements "ProductIdentifier", :subset, :cardinality => 1..n
    element "PriceType", :subset, :shortcut => :type, :cardinality => 0..1
    element "PriceAmount", :float,
            {
              :shortcut => :amount,
              :parse_lambda => lambda { |v| (v * 100).round },
              :serialize_lambda => lambda { |v| v / 100.0 },
              :cardinality => 1
            }
    element "CurrencyCode", :text, :shortcut => :currency, :cardinality => 0..1
  end
end