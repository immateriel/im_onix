module ONIX

  class Tax < SubsetDSL
    element "TaxAmount", :float, {:lambda=>lambda{|v| (v*100).round}}
    element "TaxRatePercent", :float
    element "TaxRateCode", :subset

    # shortcuts
    def rate_code
      @tax_rate_code
    end
  end
end
