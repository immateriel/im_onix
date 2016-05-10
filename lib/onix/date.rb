module ONIX

  module DateHelper
    attr_accessor :date_format, :date

    def parse_date(n)
      @date_format=DateFormat.from_code("00")
      date_txt=nil
      @date=nil
      n.elements.each do |t|
        case t
          when tag_match("DateFormat")
            @date_format=DateFormat.parse(t)
          when tag_match("Date")
            date_txt=t.text
        end

        if t["dateformat"]
          @date_format = DateFormat.from_code(t["dateformat"])
        end
      end

      code_format=format_from_code(@date_format.code)
      text_format=format_from_string(date_txt)

      format=code_format

      if code_format!=text_format
#        puts "EEE date #{n.text} (#{text_format}) do not match code #{@format.code} (#{code_format})"
        format=text_format
      end

      begin
        if format
          case @date_format.code
            when "00"
              @date=Date.strptime(date_txt, format)
            when "01"
              @date=Date.strptime(date_txt, format)
            when "14"
              @date=Time.strptime(date_txt, format)
            else
              @date=nil
          end
        end
      rescue
        # invalid date
      end
    end

    def format_from_code(code)
      case code
        when "00"
          "%Y%m%d"
        when "01"
          "%Y%m"
        when "14"
          "%Y%m%dT%H%M%S%z"
        else
          nil
      end
    end

    def format_from_string(str)
      case str
        when /^\d{4}\d{2}\d{2}T\d{2}\d{2}\d{2}/
          "%Y%m%dT%H%M%S%z"
        when /^\d{4}\d{2}\d{2}$/
          "%Y%m%d"
        when /^\d{4}\d{2}$/
          "%Y%m"
        else
          nil
      end
    end

    def time
      @date.to_time
    end
  end

  class MarketDate < SubsetDSL
    include DateHelper
    element "Date", :ignore
    element "DateFormat", :ignore
    element "MarketDateRole", :subset

    def role
      @market_date_role
    end

    def parse(n)
      super
      parse_date(n)
    end
  end

  class PriceDate < SubsetDSL
    include DateHelper
    element "Date", :ignore
    element "DateFormat", :ignore
    element "PriceDateRole", :subset

    def role
      @price_date_role
    end

    def parse(n)
      super
      parse_date(n)
    end
  end

  class SupplyDate < SubsetDSL
    include DateHelper
    element "Date", :ignore
    element "DateFormat", :ignore
    element "SupplyDateRole", :subset

    def role
      @supply_date_role
    end

    def parse(n)
      super
      parse_date(n)
    end
  end

  class PublishingDate < SubsetDSL
    include DateHelper
    element "Date", :ignore
    element "DateFormat", :ignore
    element "PublishingDateRole", :subset

    def role
      @publishing_date_role
    end

    def parse(n)
      super
      parse_date(n)
    end
  end

  class ContentDate < SubsetDSL
    include DateHelper
    element "Date", :ignore
    element "DateFormat", :ignore
    element "ContentDateRole", :subset

    def role
      @content_date_role
    end

    def parse(n)
      super
      parse_date(n)
    end
  end
end