module ONIX
  class Identifier < SubsetDSL
    class << self
      def identifier_elements(id_type)
        element id_type, :subset, :shortcut => :type, :cardinality => 1
        element "IDTypeName", :text, :shortcut => :name, :cardinality => 0..1
        element "IDValue", :text, :shortcut => :value, :cardinality => 1
      end
    end

    def uniq_id
      "#{type.code}-#{value}"
    end
  end

  class SenderIdentifier < Identifier
    identifier_elements "SenderIDType"
  end

  class AddresseeIdentifier < Identifier
    identifier_elements "AddresseeIDType"
  end

  class RecordSourceIdentifier < Identifier
    identifier_elements "RecordSourceIDType"
  end

  class AgentIdentifier < Identifier
    identifier_elements "AgentIDType"
  end

  class ImprintIdentifier < Identifier
    identifier_elements "ImprintIDType"
  end

  class PublisherIdentifier < Identifier
    identifier_elements "PublisherIDType"
  end

  class SupplierIdentifier < Identifier
    identifier_elements "SupplierIDType"
  end

  class NameIdentifier < Identifier
    identifier_elements "NameIDType"
  end

  class CollectionIdentifier < Identifier
    identifier_elements "CollectionIDType"
  end

  class ProductIdentifier < Identifier
    identifier_elements "ProductIDType"
  end

  class ProductContactIdentifier < Identifier
    identifier_elements "ProductContactIDType"
  end

  class SalesOutletIdentifier < Identifier
    identifier_elements "SalesOutletIDType"
  end

  class WorkIdentifier < Identifier
    identifier_elements "WorkIDType"
  end

  class SupplyContactIdentifier < Identifier
    identifier_elements "SupplyContactIDType"
  end

  class TextItemIdentifier < Identifier
    identifier_elements "TextItemIDType"
  end

  module IdentifiersMethods
    module Ean
      # EAN string identifier from identifiers
      # @return [String]
      def ean
        if ean_identifier
          ean_identifier.value
        else
          nil
        end
      end

      private

      def ean_identifier
        self.identifiers.select { |id| id.type.human == "Gtin13" }.first || self.identifiers.select { |id| id.type.human == "Isbn13" }.first
      end
    end

    module Isbn
      # ISBN-13 string identifier from identifiers
      # @return [String]
      def isbn13
        if isbn13_identifier
          isbn13_identifier.value
        else
          nil
        end
      end

      private

      def isbn13_identifier
        self.identifiers.select { |id| id.type.human == "Isbn13" }.first
      end
    end

    module Gln
      # GLN string identifier from identifiers
      # @return [String]
      def gln
        if gln_identifier
          if gln_identifier.value =~ /\d{13}/
            gln_identifier.value
          else
            # puts "WARN Invalid GLN #{gln_identifier.value}"
            nil
          end
        else
          nil
        end
      end

      # private
      def gln_identifier
        self.identifiers.select { |id| id.type.human == "Gln" }.first
      end
    end

    module ProprietaryId
      def proprietary_ids
        self.identifiers.select { |id| id.type.human == "Proprietary" }
      end
    end
  end
end
