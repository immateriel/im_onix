module ONIX
  class RelatedProduct < Subset
    attr_accessor :code
    # product Identifier array
    attr_accessor :identifiers
    # full Product if referenced in ONIXMessage
    attr_accessor :product

    include EanMethods

    def initialize
      @identifiers = []
    end

    def parse(n)
      n.children.each do |t|
        case t.name
          when "ProductIdentifier"
            @identifiers << Identifier.parse_identifier(t,"Product")
          when "ProductRelationCode"
            @code=ProductRelationCode.from_code(t.text)
        end
      end
    end

  end

  class RelatedWork < Subset
    attr_accessor :code, :identifiers,
                  :product

    include EanMethods

    def initialize
      @identifiers=[]
    end

    def parse(n)
      n.children.each do |t|
        case t.name
          when "WorkIdentifier"
            @identifiers << Identifier.parse_identifier(t,"Work")
          when "WorkRelationCode"
            @code=WorkRelationCode.from_code(t.text)
        end
      end
    end

  end
  class RelatedMaterial < Subset
    attr_accessor :related_products, :related_works

    def initialize
      @related_products=[]
      @related_works=[]
    end

    # :category: High level
    # paper linking RelatedProduct
    def paper_linking
      papers=@related_products.select{|rp| rp.code.human=="EpublicationBasedOnPrintProduct"}
      if papers.length > 0
        papers.first
      else
        nil
      end
    end

    def parse(n)
      n.children.each do |t|
        case t.name
          when "RelatedProduct"
            @related_products << RelatedProduct.from_xml(t)
          when "RelatedWork"
            @related_works << RelatedWork.from_xml(t)
        end
      end

    end
  end

end