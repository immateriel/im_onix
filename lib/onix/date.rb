module ONIX
  module DateHelper
    # @return [DateFormat]
    attr_accessor :date_format
    # @return [Date]
    attr_accessor :date
    # @return [Time]
    attr_accessor :datetime

    def parse_date
      if @date_format
        @deprecated_date_format = true
      else
        if @date.is_a?(TextWithAttributes)
          @date_format = @date.attributes["dateformat"]
        end
      end

      @datetime = strpdate!(@date, @date_format)
      @date = @datetime ? @datetime.to_date : nil
    end

    # @param [String] date_txt
    # @param [DateFormat] date_format
    # @return [Time]
    def strpdate!(date_txt, date_format)
      date_format ||= DateFormat.from_code("00")
      code_format = format_from_code(date_format.code)
      text_format = format_from_string(date_txt)

      format = code_format

      if code_format != text_format
        # puts "WARN incorrect date format #{text_format} != #{code_format}"
        format = text_format
      end

      begin
        datetime = Time.strptime(date_txt, format) if format && %w[00 01 02 05 13 14].include?(date_format.code)
      rescue => e
        # invalid date
      end

      datetime
    end

    # @param [String] code
    # @return [String]
    def format_from_code(code)
      case code
      when "00"
        "%Y%m%d"
      when "01"
        "%Y%m"
      when "02"
        "%Y%%W"
      when "05"
        "%Y"
      when "13"
        "%Y%m%dT%H%M%S"
      when "14"
        "%Y%m%dT%H%M%S%z"
      else
        nil
      end
    end

    # @param [String] str
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

    # @return [Time]
    def time
      @datetime
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

    def self.from_code(code)
      ds = self.new
      ds.parse(code)
      ds
    end

    def human
      @datetime
    end

    def code
      @format ? @datetime.strftime(@format) : @datetime
    end
  end

  class BaseDate < SubsetDSL
    include DateHelper
    element "DateFormat", :subset
    element "Date", :text

    # use former date representation
    # @return [Boolean]
    attr_accessor :deprecated_date_format

    def initialize
      super
      @deprecated_date_format = false
    end

    def parse(n)
      super
      parse_date
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
