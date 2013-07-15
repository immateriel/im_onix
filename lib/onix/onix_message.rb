require 'nokogiri'
require 'pp'
require 'time'

require 'onix/helper'
require 'onix/code'
require 'onix/contributor'
require 'onix/product_supply'
require 'onix/product'

module ONIX

  class Sender < Subset
    attr_accessor :identifiers, :name

    def parse(sender)
      @identifiers=Identifier.parse_identifiers(sender,"Sender")
      if sender.at("./SenderName")
        @name=sender.at("./SenderName").text
      end
    end
  end
  class ONIXMessage
    attr_accessor :sender, :sent_date_time, :default_language_of_text, :default_currency_code, :products, :vault

    def initialize
      @products=[]
      @vault={}
    end

    def parse(file)
      xml=Nokogiri::XML.parse(File.open(file))
      xml.remove_namespaces!

      header=xml.at("//Header")
      if header
        if header.at("./Sender")
          @sender=Sender.from_xml(header.at("./Sender"))
        end

        if header.at("./SentDateTime")
          tm=header.at("./SentDateTime").text
          @sent_date_time=Time.strptime(tm,"%Y%m%dT%H%M%S") rescue Time.strptime(tm,"%Y%m%dT%H%M") rescue Time.strptime(tm,"%Y%m%d") rescue nil
        end

        if header.at("./DefaultLanguageOfText")
          @default_language_of_text=header.at("./DefaultLanguageOfText").text
        end

        if header.at("./DefaultCurrencyCode")
          @default_currency_code=header.at("./DefaultCurrencyCode").text
        end

        end

#      pp @sender.identifiers

#      puts "ONIXMessage : parse XML"
      xml.search("//Product").each do |p|
        product=Product.from_xml(p)
#        product.message=self
        @products << product
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