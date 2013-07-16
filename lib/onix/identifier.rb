module ONIX
  class Identifier
    # IDType code object
    attr_accessor :type
    # IDValue string value
    attr_accessor :value

    # create Identifier array from Nokogiri:XML::Node
    def self.parse_identifiers(node,prefix_tag)
      identifiers=[]
      node.xpath("./#{prefix_tag}Identifier").each do |id|
        identifiers << Identifier.from_hash({:type=>ONIX.const_get("#{prefix_tag}IDType").from_code(id.at_xpath("./#{prefix_tag}IDType").text), :value=>id.at_xpath("./IDValue").text})
      end
      identifiers
    end

    private
    # identifier from hash
    def self.from_hash(h)
      o=self.new
      o.type=h[:type]
      o.value=h[:value]
      o
    end

  end

  module EanMethods
    # EAN string identifier from identifiers
    def ean
      if ean_identifier
        ean_identifier.value
      else
        nil
      end
    end

    private
    def ean_identifier
      @identifiers.select{|id| id.type.human=="Gtin13"}.first || @identifiers.select{|id| id.type.human=="Isbn13"}.first
    end
  end

  module GlnMethods
    # GLN string identifier from identifiers
    def gln
      if gln_identifier
        gln_identifier.value
      else
        nil
      end
    end
    # private
    def gln_identifier
      @identifiers.select{|id| id.type.human=="Gln"}.first
    end
  end
end