require 'onix/related_product'
require 'onix/related_work'
module ONIX
  class RelatedMaterial < SubsetDSL
    elements "RelatedProduct", :subset
    elements "RelatedWork", :subset

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
  end
end
