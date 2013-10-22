module ONIX
  class RelatedProduct < Subset
    attr_accessor :code
    # product Identifier array
    attr_accessor :identifiers
    # full Product if referenced in ONIXMessage
    attr_accessor :product

    attr_accessor :form

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
          when "ProductForm"
            @form=ProductForm.from_code(t.text)
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

    def linking(human)
      @related_products.select{|rp| rp.code.human==human}
    end

    # :category: High level
    # print products RelatedProduct array
    def print_products
      linking("EpublicationBasedOnPrintProduct") + self.alternative_format_products.select{|rp| rp.form.code=~/^B/}
    end

    # :category: High level
    # is part of products RelatedProduct array
    def part_of_products
      linking("IsPartOf")
    end

    # :category: High level
    # alternative format products RelatedProduct array
    def alternative_format_products
      linking("AlternativeFormat")
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