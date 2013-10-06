module ONIX
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

      case @format.code
        when "00"
          @date=Date.strptime(n.text, "%Y%m%d")
        when "01"
          @date=Date.strptime(n.text, "%Y%m")
        when "14"
          @date=Time.strptime(n.text, "%Y%m%dT%H%M%S")
        else
          @date=nil
      end

    end

    def time
      @date.to_time
    end

  end
end