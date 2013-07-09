module ONIX

  class Tax < Subset
    attr_accessor :amount, :rate_code, :rate_percent
    def parse(tx)
      if tx.at("./TaxAmount")
        @amount=(tx.at("./TaxAmount").text.to_f * 100).round
      end
      @rate_percent=tx.at("./TaxRatePercent").text.to_f

      if tx.at("./TaxRateCode")
        @rate_code=TaxRateCode.from_code(tx.at("./TaxRateCode").text)
      end
    end

  end

  class PriceDate < Subset
    attr_accessor :role, :date
    def parse(prd)
      @role = PriceDateRole.from_code(prd.at("./PriceDateRole").text)
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
      pr.search("./PriceDate").each do |prd|
        @dates << PriceDate.from_xml(prd)
      end

      if pr.at("./CurrencyCode")
        @currency=pr.at("./CurrencyCode").text
      end

      if pr.at("./Territory")
        @territory=Territory.from_xml(pr.at("./Territory"))
      end

      @type=PriceType.from_code(pr.at("./PriceType").text)
      @amount=(pr.at("./PriceAmount").text.to_f * 100).round

      if pr.at("./Tax")
        @tax=Tax.from_xml(pr.at("./Tax"))
      end

    end
  end
end