module ONIX

  class Tax < Subset
    attr_accessor :amount, :rate_percent
    def parse(tx)
      @amount=(tx.at("./TaxAmount").text.to_f * 100).round
      @rate_percent=tx.at("./TaxRatePercent").text.to_f
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
      self.type.human=~/IncludingTax/
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