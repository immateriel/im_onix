module ONIX
  class Subset

    # instanciate Subset form Nokogiri::XML::Node
    def self.from_xml(n)
      o=self.new
      o.parse(n)
      o
    end

    # parse Nokogiri::XML::Node
    def parse(n)
    end

  end
end