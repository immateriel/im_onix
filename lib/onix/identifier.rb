module ONIX
  class Identifier < SubsetDSL
    element "IDValue", :text
    element "IDTypeName", :text

    def value
      @id_value
    end

    def name
      @id_type_name
    end

    def type
      nil
    end

    def uniq_id
      "#{type.code}-#{value}"
    end
  end

  class SenderIdentifier < Identifier
    element "SenderIDType", :subset
    def type
      @sender_id_type
    end
  end

  class AddresseeIdentifier < Identifier
    element "AddresseeIDType", :subset
    def type
      @addressee_id_type
    end
  end

  class AgentIdentifier < Identifier
    element "AgentIDType", :subset
    def type
      @agent_id_type
    end
  end

  class PublisherIdentifier < Identifier
    element "PublisherIDType", :subset
    def type
      @publisher_id_type
    end
  end

  class SupplierIdentifier < Identifier
    element "SupplierIDType", :subset
    def type
      @supplier_id_type
    end
  end

  class NameIdentifier < Identifier
    element "NameIDType", :subset
    def type
      @name_id_type
    end
  end

  class CollectionIdentifier < Identifier
    element "CollectionIDType", :subset
    def type
      @collection_id_type
    end
  end

  class ProductIdentifier < Identifier
    element "ProductIDType", :subset
    def type
      @product_id_type
    end
  end

  class SalesOutletIdentifier < Identifier
    element "SalesOutletIDType", :subset
    def type
      @sales_outlet_id_type
    end
  end

  class WorkIdentifier < Identifier
    element "WorkIDType", :subset
    def type
      @work_id_type
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
      self.identifiers.select { |id| id.type.human=="Gtin13" }.first || self.identifiers.select { |id| id.type.human=="Isbn13" }.first
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
