module ONIX
  class Helper

    def self.text_at(n,xpath)
      if n.at(xpath)
        n.at(xpath).text.strip
      else
        nil
      end
    end

    def self.mandatory_text_at(n,xpath)
      self.text_at(n,xpath)
    end

    def self.to_date(date_format,date_str)
      date_str_f=date_str.gsub(/\-/, "").gsub(/\:/, "")
      case date_format
        when "00"
          Date.strptime(date_str_f, "%Y%m%d")
        when "01"
          Date.strptime(date_str_f, "%Y%m")
        when "14"
          Time.strptime(date_str_f, "%Y%m%dT%H%M%S")
        else
          nil
      end
    end

    def self.parse_date(pd)
      date=nil
      if pd and pd.at("./Date")
        begin
          date_str=pd.at("./Date").text
          date_format="00"
          if pd.at("./DateFormat")
            date_format=pd.at("./DateFormat").text
          end
          # devrait être dans le convertisseur auto de date
            date=self.to_date(date_format,date_str)
            unless date
              date=date_str
            end
        rescue
          date=nil
        end

#        puts date
        case date
          when /^\d{4}$/
            date=Date.new(date_str_f.to_i,1,1)
        end

      end
      date
    end

  end
end