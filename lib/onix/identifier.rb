module ONIX
  class Identifier < Subset
    # IDType code object
    attr_accessor :type
    # IDValue string value
    attr_accessor :value
    # IDTypeName string value
    attr_accessor :name

    # create Identifier array from Nokogiri:XML::Node
    def self.parse_identifiers(node,prefix_tag)
      identifiers=[]
      node.children.each do |id|
        case id
          when tag_match("#{prefix_tag}Identifier")
            identifiers << self.parse_identifier(id,prefix_tag)
        end
      end
      identifiers
    end

    def self.parse_identifier(node,prefix_tag)
      id_type=nil
      id_value=nil
      id_type_name=nil
      node.children.each do |id|
        case id
          when tag_match("#{prefix_tag}IDType")
            id_type=id.text
          when tag_match("IDValue")
            id_value=id.text
          when tag_match("IDTypeName")
            id_type_name = id.text
        end
      end
      identifier = Identifier.from_hash({:type => ONIX.const_get("#{prefix_tag}IDType").from_code(id_type), :value => id_value})
      identifier.name = id_type_name
      identifier
    end

    def uniq_id
      "#{type.code}-#{@value}"
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
        if gln_identifier.value =~ /\d{13}/
          gln_identifier.value
        else
          puts "Invalid GLN #{gln_identifier.value}"
          nil
        end
      else
        nil
      end
    end
    # private
    def gln_identifier
      @identifiers.select{|id| id.type.human=="Gln"}.first
    end
  end

  module ProprietaryIdMethods
    def proprietary_ids
      @identifiers.select{|id| id.type.human=="Proprietary"}
    end
  end
end
