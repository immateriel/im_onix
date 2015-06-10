module ONIX
  class Helper
    # convert arbitrary arg to File/String
    def self.arg_to_data(arg)
      data=""
      case arg
        when String
          if File.file?(arg)
            data=File.open(arg)
          else
            data=arg
          end
        when File, Tempfile
          data=arg.read
      end
      data
    end

    # traverse each product as xml string
    def self.each_xml_product(arg, &block)
      data=self.arg_to_data(arg)
      Nokogiri::XML::Reader(data).each do |node|
        if node.name == 'Product' and node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          yield(node.outer_xml)
        end
      end
    end

    # traverse each product as xml string with added ONIXMessage
    def self.each_xml_product_as_full_message(arg, &block)
      self.each_xml_product(arg) do |p|
        yield("<ONIXMessage>\n"+p+"\n</ONIXMessage>\n")
      end
    end

    def self.text_at(n,xpath)
      if n.at_xpath(xpath)
        n.at_xpath(xpath).text.strip
      else
        nil
      end
    end

    def self.mandatory_text_at(n,xpath)
      self.text_at(n,xpath)
    end

    def self.strip_html(html)
      html.gsub(/&nbsp;/," ").gsub(/<[^>]*(>+|\s*\z)/m, '')
    end

    def self.to_date(date_format,date_str_f)
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
          date_str_f=date_str.gsub(/\-/, "").gsub(/\:/, "")

          # devrait être dans le convertisseur auto de date
            date=self.to_date(date_format,date_str_f)
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