module ONIX
  class Identifier < SubsetDSL
    element "IDTypeName", :text, :shortcut => :name, :cardinality => 0..1
    element "IDValue", :text, :shortcut => :value, :cardinality => 1

    def type
      nil
    end

    def uniq_id
      "#{type.code}-#{value}"
    end
  end

  class SenderIdentifier < Identifier
    element "SenderIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class AddresseeIdentifier < Identifier
    element "AddresseeIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class RecordSourceIdentifier < Identifier
    element "RecordSourceIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class AgentIdentifier < Identifier
    element "AgentIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class ImprintIdentifier < Identifier
    element "ImprintIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class PublisherIdentifier < Identifier
    element "PublisherIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class SupplierIdentifier < Identifier
    element "SupplierIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class NameIdentifier < Identifier
    element "NameIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class CollectionIdentifier < Identifier
    element "CollectionIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class ProductIdentifier < Identifier
    element "ProductIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class ProductContactIdentifier < Identifier
    element "ProductContactIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class SalesOutletIdentifier < Identifier
    element "SalesOutletIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class WorkIdentifier < Identifier
    element "WorkIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class SupplyContactIdentifier < Identifier
    element "SupplyContactIDType", :subset, :shortcut => :type, :cardinality => 1
  end

  class TextItemIdentifier < Identifier
    element "TextItemIDType", :subset, :shortcut => :type, :cardinality => 1
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
      self.identifiers.select { |id| id.type.human=="Gtin13" }.first || self.identifiers.select { |id| id.type.human=="Isbn13" }.first
    end
  end

  module IsbnMethods
    # ISBN-13 string identifier from identifiers
    def isbn13
      if isbn13_identifier
        isbn13_identifier.value
      else
        nil
      end
    end

    private
    def isbn13_identifier
      self.identifiers.select{|id| id.type.human=="Isbn13"}.first
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
      self.identifiers.select { |id| id.type.human=="Gln" }.first
    end
  end

  module ProprietaryIdMethods
    def proprietary_ids
      self.identifiers.select { |id| id.type.human=="Proprietary" }
    end
  end
end
