module ONIX

  class Tax < Subset
    attr_accessor :amount, :rate_code, :rate_percent
    def parse(tx)
      if tx.at_xpath("./TaxAmount")
        @amount=(tx.at_xpath("./TaxAmount").text.to_f * 100).round
      end
      @rate_percent=tx.at_xpath("./TaxRatePercent").text.to_f

      if tx.at_xpath("./TaxRateCode")
        @rate_code=TaxRateCode.from_code(tx.at_xpath("./TaxRateCode").text)
      end
    end

  end

  class PriceDate < Subset
    attr_accessor :role, :date
    def parse(prd)
      @role = PriceDateRole.from_code(prd.at_xpath("./PriceDateRole").text)
      @date = Helper.parse_date(prd)
    end
  end

  class Price < Subset
    attr_accessor :amount, :type, :currency, :dates, :territory

    def initialize
      @dates=[]
    end

    def from_date
      dt=@dates.select{|d| d.role.human=="FromDate"}.first
      if dt
        dt.date
      else
        nil
      end
    end

    def until_date
      dt=@dates.select{|d| d.role.human=="UntilDate"}.first
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

    def parse(pr)
      pr.xpath("./PriceDate").each do |prd|
        @dates << PriceDate.from_xml(prd)
      end

      if pr.at_xpath("./CurrencyCode")
        @currency=pr.at_xpath("./CurrencyCode").text
      end

      if pr.at_xpath("./Territory")
        @territory=Territory.from_xml(pr.at_xpath("./Territory"))
      end

      @type=PriceType.from_code(pr.at("./PriceType").text)
      @amount=(pr.at_xpath("./PriceAmount").text.to_f * 100).round

      if pr.at_xpath("./Tax")
        @tax=Tax.from_xml(pr.at_xpath("./Tax"))
      end

    end
  end
end