require 'onix/related_product'
require 'onix/related_work'
module ONIX
  class RelatedMaterial < SubsetDSL
    elements "RelatedWork", :subset, :cardinality => 0..n
    elements "RelatedProduct", :subset, :cardinality => 0..n

    # @!group High level

    # @return [Array<RelatedProduct>]
    def linking(human)
      @related_products.select{|rp| rp.code.human==human}
    end

    # print products RelatedProduct array
    # @return [Array<RelatedProduct>]
    def print_products
      linking("EpublicationBasedOnPrintProduct") + self.alternative_format_products.select{|rp| rp.form && rp.form.code=~/^B/}
    end

    # is part of products RelatedProduct array
    # @return [Array<RelatedProduct>]
    def part_of_products
      linking("IsPartOf")
    end

    # alternative format products RelatedProduct array
    # @return [Array<RelatedProduct>]
    def alternative_format_products
      linking("AlternativeFormat")
    end

    # @!endgroup
  end
end
