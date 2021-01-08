module ONIX
  module DateHelper
    attr_accessor :date_format, :date

    def initialize
      @date_format = DateFormat.from_code("00")
    end

    def parse_date(n)
      date_txt = nil
      @date = nil
      n.elements.each do |t|
        case t
        when tag_match("DateFormat")
          @date_format = DateFormat.parse(t)
          @deprecated_date_format = true
        when tag_match("Date")
          date_txt = t.text
        end

        if t["dateformat"]
          @date_format = DateFormat.from_code(t["dateformat"])
        end
      end

      strpdate!(date_txt)
    end

    def strpdate!(date_txt)
      code_format = format_from_code(@date_format.code)
      text_format = format_from_string(date_txt)

      format = code_format

      if code_format != text_format
        format = text_format
      end

      begin
        if format
          case @date_format.code
          when "00"
            @date = Date.strptime(date_txt, format)
          when "01"
            @date = Date.strptime(date_txt, format)
          when "05"
            @date = Date.strptime(date_txt, format)
          when "14"
            @date = Time.strptime(date_txt, format)
          else
            @date = nil
          end
        end
      rescue => e
        # invalid date
      end
    end

    def format_from_code(code)
      case code
      when "00"
        "%Y%m%d"
      when "01"
        "%Y%m"
      when "05"
        "%Y"
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
      when /^\d{4}\-\d{2}\-\d{2}$/
        "%Y-%m-%d"
      when /^\d{4}\d{2}\d{2}$/
        "%Y%m%d"
      when /^\d{4}\d{2}$/
        "%Y%m"
      when /^\d{4}$/
        "%Y"
      else
        nil
      end
    end

    def time
      @date.to_time
    end
  end

  # support for datestamp attribute and SentDateTime
  class DateStamp
    attr_accessor :format, :datetime

    def initialize(dt = nil, fmt = "%Y%m%d")
      @datetime = dt
      @format = fmt unless @datetime.is_a?(String)
    end

    def supported_formats
      ["%Y%m%dT%H%M%S%z", "%Y%m%dT%H%M%S", "%Y%m%dT%H%M%z", "%Y%m%dT%H%M", "%Y%m%d"]
    end

    def parse(tm)
      @format = nil
      found_format = nil
      supported_formats.each do |supported_format|
        begin
          @datetime = Time.strptime(tm, supported_format)
          found_format = supported_format
          break
        rescue
        end
      end
      @format = found_format
      @datetime = tm unless @format
    end

    def code
      @format ? @datetime.strftime(@format) : @datetime
    end
  end

  class BaseDate < SubsetDSL
    include DateHelper
    element "Date", :ignore
    element "DateFormat", :ignore
    attr_accessor :deprecated_date_format

    def initialize
      super
      @deprecated_date_format = false
    end

    def parse(n)
      super
      parse_date(n)
    end
  end

  class MarketDate < BaseDate
    element "MarketDateRole", :subset, :shortcut => :role

    scope :availability, lambda { human_code_match(:market_date_role, ["PublicationDate", "EmbargoDate"]) }
  end

  class PriceDate < BaseDate
    element "PriceDateRole", :subset, :shortcut => :role

    scope :from_date, lambda { human_code_match(:price_date_role, "FromDate") }
    scope :until_date, lambda { human_code_match(:price_date_role, "UntilDate") }
  end

  class SupplyDate < BaseDate
    element "SupplyDateRole", :subset, :shortcut => :role

    scope :availability, lambda { human_code_match(:supply_date_role, ["ExpectedAvailabilityDate", "EmbargoDate"]) }
  end

  class PublishingDate < BaseDate
    element "PublishingDateRole", :subset, :shortcut => :role

    scope :publication, lambda { human_code_match(:publishing_date_role, ["PublicationDate", "PublicationDateOfPrintCounterpart"]) }
    scope :embargo, lambda { human_code_match(:publishing_date_role, "SalesEmbargoDate") }
    scope :preorder_embargo, lambda { human_code_match(:publishing_date_role, "PreorderEmbargoDate") }
    scope :public_announcement, lambda { human_code_match(:publishing_date_role, "PublicAnnouncementDate") }
  end

  class ContentDate < BaseDate
    element "ContentDateRole", :subset, :shortcut => :role

    scope :last_updated, lambda { human_code_match(:content_date_role, "LastUpdated") }
  end

  class ContributorDate < BaseDate
    element "ContributorDateRole", :subset, :shortcut => :role
  end
end
