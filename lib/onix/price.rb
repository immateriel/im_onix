require 'onix/onix_date'

module ONIX

  class Tax < Subset
    attr_accessor :amount, :rate_code, :rate_percent
    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("TaxAmount")
            @amount=(t.text.to_f * 100).round
          when tag_match("TaxRatePercent")
            @rate_percent=t.text.to_f
          when tag_match("TaxRateCode")
            @rate_code=TaxRateCode.parse(t)
        end
      end
    end
  end

  class PriceDate < Subset
    attr_accessor :role, :date
    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("PriceDateRole")
            @role = PriceDateRole.parse(t)
          when tag_match("Date")
            # via OnixDate
          when tag_match("DateFormat")
            # via OnixDate
          else
            unsupported(t)
        end
      end
      @date = OnixDate.parse(n)
    end

  end

  class Price < Subset
    attr_accessor :amount, :type, :qualifier, :currency, :dates, :territory, :discount

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
      n.elements.each do |t|
        case t
          when tag_match("PriceDate")
            @dates << PriceDate.parse(t)
          when tag_match("CurrencyCode")
            @currency=t.text.strip
          when tag_match("Territory")
            @territory=Territory.parse(t)
          when tag_match("PriceType")
            @type=PriceType.parse(t)
          when tag_match("PriceQualifier")
            @qualifier=PriceQualifier.parse(t)
          when tag_match("PriceAmount")
            @amount=(t.text.to_f * 100).round
          when tag_match("PriceStatus")
            @qualifier=PriceStatus.parse(t)
          when tag_match("Tax")
            @tax=Tax.parse(t)
          when tag_match("DiscountCoded")
            @discount = Discount.parse(t)
          else
            unsupported(t)
        end
      end
    end
  end

  class Discount < Subset
    attr_accessor :code_type, :code_type_name, :code

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("DiscountCodeType")
            @code_type = t.text
          when tag_match("DiscountCodeTypeName")
            @code_type_name = t.text
          when tag_match("DiscountCode")
            @code = t.text
          else
            unsupported(t)
        end
      end
    end
  end
end
