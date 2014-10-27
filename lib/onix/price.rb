require 'onix/onix_date'

module ONIX

  class Tax < Subset
    attr_accessor :amount, :rate_code, :rate_percent
    def parse(n)
      n.children.each do |t|
        case t.name
          when "TaxAmount"
            @amount=(t.text.to_f * 100).round
          when "TaxRatePercent"
            @rate_percent=t.text.to_f
          when "TaxRateCode"
            @rate_code=TaxRateCode.from_code(t.text)
        end
      end
    end
  end

  class PriceDate < Subset
    attr_accessor :role, :date
    def parse(n)
      n.children.each do |t|
        case t.name
          when "PriceDateRole"
            @role = PriceDateRole.from_code(t.text)
          when "Date"
            @date = OnixDate.from_xml(t)
        end
      end
#      @date = Helper.parse_date(n)
    end

  end

  class Price < Subset
    attr_accessor :amount, :type, :currency, :dates, :territory, :discount

    def initialize
      @dates=[]
    end

    def from_date
      dt=@dates.select{|d| d.role.human=="FromDate"}.first
      if dt
          dt.date.date
      else
        nil
      end
    end

    def until_date
      dt=@dates.select { |d| d.role.human=="UntilDate" }.first
      if dt
        dt.date.date
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

    def parse(n)
      n.children.each do |t|
        case t.name
          when "PriceDate"
            @dates << PriceDate.from_xml(t)
          when "CurrencyCode"
            @currency=t.text.strip
          when "Territory"
            @territory=Territory.from_xml(t)
          when "PriceType"
            @type=PriceType.from_code(t.text)
          when "PriceAmount"
            @amount=(t.text.to_f * 100).round
          when "Tax"
            @tax=Tax.from_xml(t)
          when "DiscountCoded"
            @discount = Discount.from_xml(t)
        end
      end
    end
  end

  class Discount < Subset
    attr_accessor :code_type, :code_type_name, :code

    def parse(n)
      n.children.each do |t|
        case t.name
          when "DiscountCodeType"
            @code_type = t.text
          when "DiscountCodeTypeName"
            @code_type_name = t.text
          when "DiscountCode"
            @code = t.text
        end
      end
    end
  end
end
