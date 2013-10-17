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
            @identifiers << Identifier.parse_identifier(t, "Sender")
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


    # parse filename or file
    def parse(arg)
      data=""
      case arg
        when String
          if File.file?(arg)
            data=File.open(arg)
          else
            data=arg
          end
        when File, Tempfile
          data=arg.read
      end

      xml=Nokogiri::XML.parse(data)
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
        product.identifiers.each do |ident|
          @vault[ident.uniq_id]=product
        end
      end

#      puts "ONIXMessage : chain products from vault"
      @products.each do |product|
        if product.related_material
          product.related_material.related_products.each do |rp|
            rp.identifiers.each do |ident|
              if @vault[ident.uniq_id]
#              puts "Vault found for related product #{rp.ean}"
                rp.product=@vault[ident.uniq_id]
              end

            end
          end

          product.related_material.related_works.each do |rw|
            rw.identifiers.each do |ident|
              if @vault[ident.uniq_id]
#              puts "Vault found for related work #{rw.ean}"
                rw.product=@vault[ident.uniq_id]
              end
            end
          end
        end

        product.descriptive_detail.parts.each do |prt|
          prt.identifiers.each do |ident|
              if @vault[ident.uniq_id]
#              puts "Vault found for product part #{prt.ean}"
                prt.product=@vault[ident.uniq_id]
              end
          end
        end
      end
    end
  end
end