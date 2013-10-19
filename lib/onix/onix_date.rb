module ONIX
  # FIXME : support only 00,01 and 14 date format
  class OnixDate < Subset
    attr_accessor :format, :date

    def parse(n)
      @format=DateFormat.from_code("00")
      @date=nil
      n.children.each do |t|
        case t.name
          when "DateFormat"
            @format=DateFormat.from_code(t.text)
        end
      end

      code_format=format_from_code(@format.code)
      text_format=format_from_string(n.text)

      format=code_format

      if code_format!=text_format
#        puts "EEE date #{n.text} (#{text_format}) do not match code #{@format.code} (#{code_format})"
        format=text_format
      end

      if format
      case @format.code
        when "00"
          @date=Date.strptime(n.text, format)
        when "01"
          @date=Date.strptime(n.text, format)
        when "14"
          @date=Time.strptime(n.text, format)
        else
          @date=nil
      end
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
end