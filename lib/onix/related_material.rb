module ONIX
  class RelatedProduct < Subset
    attr_accessor :code
    # product Identifier array
    attr_accessor :identifiers
    # complete Product
    attr_accessor :product

    include EanMethods

    def parse(rp)
      @code=ProductRelationCode.from_code(rp.at("./ProductRelationCode").text)
      @identifiers=Identifier.parse_identifiers(rp,"Product")
    end

  end

  class RelatedWork < Subset
    attr_accessor :code, :identifiers,
                  :product

    include EanMethods

    def parse(rw)
      @code=WorkRelationCode.from_code(rw.at("./WorkRelationCode").text)
      @identifiers=Identifier.parse_identifiers(rw,"Work")
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

    def parse(related)
      related.search("./RelatedProduct").each do |rp|
        @related_products << RelatedProduct.from_xml(rp)
      end

      related.search("./RelatedWork").each do |rw|
        @related_works << RelatedWork.from_xml(rw)
      end
    end
  end

end