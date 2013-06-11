require 'nokogiri'
require 'pp'
require 'time'

require 'onix/helper'
require 'onix/code'
require 'onix/contributor'
require 'onix/product_supply'
require 'onix/product'

module ONIX
  class ONIXMessage
    attr_accessor :products, :vault

    def initialize
      @products=[]
      @vault={}
    end

    def parse(file)
      xml=Nokogiri::XML.parse(File.open(file))
      xml.remove_namespaces!

#      puts "ONIXMessage : parse XML"
      xml.search("//Product").each do |p|
        @products << Product.from_xml(p)
      end

#      puts "ONIXMessage : produce vault"
      @products.each do |product|
        @vault[product.ean]=product
      end

#      puts "ONIXMessage : chain products from vault"
      @products.each do |product|
        if product.related_material
          product.related_material.related_products.each do |rp|
            if @vault[rp.ean]
#              puts "Vault found for related product #{rp.ean}"
              rp.product=@vault[rp.ean]
            end
          end

          product.related_material.related_works.each do |rw|
            if @vault[rw.ean]
#              puts "Vault found for related work #{rw.ean}"
              rw.product=@vault[rw.ean]
            end
          end
        end

        product.descriptive_detail.parts.each do |prt|
          if @vault[prt.ean]
#            puts "Vault found for product part #{prt.ean}"
            prt.product=@vault[prt.ean]
          end
        end
      end
    end
  end
end