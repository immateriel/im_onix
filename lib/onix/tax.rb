module ONIX
  class Tax < SubsetDSL
    element "TaxType", :subset
    element "TaxRateCode", :subset, :shortcut => :rate_code
    element "TaxRatePercent", :float, :shortcut => :rate_percent
    element "TaxableAmount", :float, {
        :parse_lambda => lambda { |v| (v * 100).round }
    }
    element "TaxAmount", :float, {
        :shortcut => :amount,
        :parse_lambda => lambda { |v| (v * 100).round }
    }
  end
end
