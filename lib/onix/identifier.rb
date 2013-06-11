module ONIX
  class Identifier
    attr_accessor :type, :value

    def self.from_hash(h)
      o=self.new
      o.type=h[:type]
      o.value=h[:value]
      o
    end

    def self.parse_identifiers(node,prefix_tag)
      identifiers=[]

      node.search("./#{prefix_tag}Identifier").each do |id|
        identifiers << Identifier.from_hash({:type=>ONIX.const_get("#{prefix_tag}IDType").from_code(id.at("./#{prefix_tag}IDType").text), :value=>id.at("./IDValue").text})
      end

      identifiers
    end

  end

  module EanMethods
    def ean
      if ean_identifier
        ean_identifier.value
      else
        nil
      end
    end

    def ean_identifier
      @identifiers.select{|id| id.type.human=="Gtin13"}.first || @identifiers.select{|id| id.type.human=="Isbn13"}.first
    end
  end

  module GlnMethods
    def gln
      if gln_identifier
        gln_identifier.value
      else
        nil
      end
    end

    def gln_identifier
      @identifiers.select{|id| id.type.human=="Gln"}.first
    end
  end
end