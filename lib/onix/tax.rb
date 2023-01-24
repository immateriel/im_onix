module ONIX

  class Tax < SubsetDSL
    element "TaxType", :subset
    element "TaxRateCode", :subset
    element "TaxRatePercent", :float
    element "TaxableAmount", :float, {:parse_lambda=>lambda{|v| (v*100).round}}
    element "TaxAmount", :float, {:parse_lambda=>lambda{|v| (v*100).round}}

    # shortcuts
    def rate_code
      @tax_rate_code
    end

    def amount
      @tax_amount
    end

    def rate_percent
      @tax_rate_percent
    end
  end
end
