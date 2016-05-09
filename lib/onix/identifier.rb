module ONIX
  class Identifier < Subset
    # IDType code object
    attr_accessor :type
    # IDValue string value
    attr_accessor :value
    # IDTypeName string value
    attr_accessor :name

    def self.prefix
      nil
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("#{self.class.prefix}IDType")
            @type=ONIX.const_get("#{self.class.prefix}IDType").parse(t)
          when tag_match("IDValue")
            @value=t.text
          when tag_match("IDTypeName")
            @name = t.text
        end
      end
    end

    def uniq_id
      "#{type.code}-#{@value}"
    end
  end

  class SenderIdentifier < Identifier
    def self.prefix
      "Sender"
    end
  end

  class AddresseeIdentifier < Identifier
    def self.prefix
      "Addressee"
    end
  end

  class AgentIdentifier < Identifier
    def self.prefix
      "Agent"
    end
  end

  class PublisherIdentifier < Identifier
    def self.prefix
      "Publisher"
    end
  end

  class SupplierIdentifier < Identifier
    def self.prefix
      "Supplier"
    end
  end

  class NameIdentifier < Identifier
    def self.prefix
      "Name"
    end
  end

  class CollectionIdentifier < Identifier
    def self.prefix
      "Collection"
    end
  end

  class ProductIdentifier < Identifier
    def self.prefix
      "Product"
    end
  end

  class SalesOutletIdentifier < Identifier
    def self.prefix
      "SalesOutlet"
    end
  end

  class WorkIdentifier < Identifier
    def self.prefix
      "Work"
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
      @identifiers.select { |id| id.type.human=="Gtin13" }.first || @identifiers.select { |id| id.type.human=="Isbn13" }.first
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
      @identifiers.select { |id| id.type.human=="Gln" }.first
    end
  end

  module ProprietaryIdMethods
    def proprietary_ids
      @identifiers.select { |id| id.type.human=="Proprietary" }
    end
  end
end
