require 'nokogiri'
require 'pp'
require 'time'
require 'benchmark'

require 'onix/helper'
require 'onix/code'
require 'onix/contributor'
require 'onix/product_supply'
require 'onix/product'

module ONIX

  class Sender < Subset
    attr_accessor :identifiers, :name

    def initialize
      @identifiers=[]
    end
    def parse(n)
      n.children.each do |t|
        case t.name
          when "SenderIdentifier"
            @identifiers << Identifier.parse_identifier(t,"Sender")
          when "SenderName"
            @name=t.text
        end
      end
    end
  end
  class ONIXMessage
    attr_accessor :sender, :sent_date_time,
                  :default_language_of_text, :default_currency_code,
                  :products, :vault

    def initialize
      @products=[]
      @vault={}
    end

    # parse filename
    def parse(file)
      xml=Nokogiri::XML.parse(File.open(file))
      xml.remove_namespaces!

      header=xml.at_xpath("//Header")
      if header
        header.children.each do |t|
          case t.name
            when "Sender"
              @sender=Sender.from_xml(t)
            when "SentDateTime"
              tm=t.text
              @sent_date_time=Time.strptime(tm, "%Y%m%dT%H%M%S") rescue Time.strptime(tm, "%Y%m%dT%H%M") rescue Time.strptime(tm, "%Y%m%d") rescue nil
            when "DefaultLanguageOfText"
              @default_language_of_text=LanguageCode.from_code(t.text)
            when "DefaultCurrencyCode"
              @default_currency_code=t.text
          end
        end
      end

#      pp @sender.identifiers

#      puts "ONIXMessage : parse XML"
      xml.xpath("//Product").each do |p|
        product=nil
#        tm=Benchmark.measure do
        product=Product.from_xml(p)
        product.default_language_of_text=@default_language_of_text
        product.default_currency_code=@default_currency_code
#        product.message=self
        @products << product
#        end
#        GC.start
#        puts "#{product.ean} #{GC.count} #{tm}"

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