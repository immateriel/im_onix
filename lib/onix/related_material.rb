module ONIX
  class RelatedProduct < Subset
    attr_accessor :code
    # product Identifier array
    attr_accessor :identifiers
    # full Product if referenced in ONIXMessage
    attr_accessor :product

    attr_accessor :form

    attr_accessor :form_details

    include EanMethods
    include ProprietaryIdMethods

    def initialize
      @identifiers = []
      @form_details = []
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("ProductIdentifier")
            @identifiers << Identifier.parse_identifier(t,"Product")
          when tag_match("ProductRelationCode")
            @code=ProductRelationCode.parse(t)
          when tag_match("ProductForm")
            @form=ProductForm.parse(t)
          when tag_match("ProductFormDetail")
            @form_details << ProductFormDetail.parse(t)
          else
            unsupported(t)
        end
      end
    end

    def file_format
      file_formats.first.human if file_formats.first
    end

    def file_formats
      @form_details.select{|fd| fd.code =~ /^E1.*/}
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
      n.elements.each do |t|
        case t
          when tag_match("WorkIdentifier")
            @identifiers << Identifier.parse_identifier(t,"Work")
          when tag_match("WorkRelationCode")
            @code=WorkRelationCode.parse(t)
          else
            unsupported(t)
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
      linking("EpublicationBasedOnPrintProduct") + self.alternative_format_products.select{|rp| rp.form && rp.form.code=~/^B/}
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
      n.elements.each do |t|
        case t
          when tag_match("RelatedProduct")
            @related_products << RelatedProduct.parse(t)
          when tag_match("RelatedWork")
            @related_works << RelatedWork.parse(t)
          else
            unsupported(t)
        end
      end
    end
  end

end
