module ONIX
  class Tax < SubsetDSL
    elements "ProductIdentifier", :subset, :cardinality => 0..n
    elements "PricePartDescription", :text, :cardinality => 0..n
    element "TaxType", :subset, :cardinality => 0..1
    element "TaxRateCode", :subset, :shortcut => :rate_code, :cardinality => 0..1
    element "TaxRatePercent", :float, :shortcut => :rate_percent, :cardinality => 0..1
    element "TaxableAmount", :float, {
        :parse_lambda => lambda { |v| (v * 100).round },
        :serialize_lambda => lambda { |v| format("%.2f", v / 100.0) },
        :cardinality => 0..1
    }
    element "TaxAmount", :float, {
        :shortcut => :amount,
        :parse_lambda => lambda { |v| (v * 100).round },
        :serialize_lambda => lambda { |v| format("%.2f", v / 100.0) },
        :cardinality => 0..1
    }
  end
end
