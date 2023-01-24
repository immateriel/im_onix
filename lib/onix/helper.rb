module ONIX
  class Helper
    # convert arbitrary arg to File/String
    # @param [String, File] arg
    def self.arg_to_data(arg)
      data = ""
      case arg
      when String
        if File.file?(arg)
          data = File.read(arg)
        else
          data = arg
        end
      when File, Tempfile
        data = arg.read
      end
      data
    end

    # traverse each product as xml string
    def self.each_xml_product(arg, &block)
      data = self.arg_to_data(arg)
      Nokogiri::XML::Reader(data).each do |node|
        if node.name == 'Product' and node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          yield(node.outer_xml)
        end
      end
    end

    # traverse each product as xml string with added ONIXMessage
    def self.each_xml_product_as_full_message(arg, &block)
      self.each_xml_product(arg) do |p|
        yield("<ONIXMessage>\n" + p + "\n</ONIXMessage>\n")
      end
    end

    # @param [String] html
    # @return [String]
    def self.strip_html(html)
      html.gsub(/&nbsp;/, " ").gsub(/<[^>]*(>+|\s*\z)/m, '')
    end

    def self.to_date(date_format, date_str_f)
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

  end
end