require 'nokogiri'
require 'pp'
require 'time'
require 'benchmark'

require 'onix/subset'

require 'onix/helper'
require 'onix/code'
require 'onix/contributor'
require 'onix/product_supply'
require 'onix/product'

module ONIX

  class Sender < Subset
    attr_accessor :identifiers, :name

    include GlnMethods

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

  class ONIXMessage < Subset
    attr_accessor :sender, :sent_date_time,
                  :default_language_of_text, :default_currency_code,
                  :products, :vault

    def initialize
      @products=[]
      @vault={}
    end

    # merge another message in this one
    # current object erase other values
    def merge!(other)
      @products+=other.products
      @products=@products.uniq{|p| p.ean}
      init_vault
      self
    end

    # keep products for which block return true
    def select! &block
      @products.select!{|p| block.call(p)}
      init_vault
      self
    end

    # initialize hash between ID and product object
    def init_vault
      @vault={}
      @products.each do |product|
        product.identifiers.each do |ident|
          @vault[ident.uniq_id]=product
        end
      end

      @products.each do |product|
        if product.related_material
          product.related_material.related_products.each do |rp|
            rp.identifiers.each do |ident|
              if @vault[ident.uniq_id]
                rp.product=@vault[ident.uniq_id]
              end

            end
          end

          product.related_material.related_works.each do |rw|
            rw.identifiers.each do |ident|
              if @vault[ident.uniq_id]
                rw.product=@vault[ident.uniq_id]
              end
            end
          end
        end

        product.descriptive_detail.parts.each do |prt|
          prt.identifiers.each do |ident|
            if @vault[ident.uniq_id]
              prt.product=@vault[ident.uniq_id]
            end
          end
        end
      end
    end

    # open with arg detection
    def open(arg,force_encoding=nil)
      data=ONIX::Helper.arg_to_data(arg)

      xml=nil
      if force_encoding
        xml=Nokogiri::XML.parse(data,nil,force_encoding)
      else
        xml=Nokogiri::XML.parse(data)
      end

      xml.remove_namespaces!
      xml
    end

    # parse filename or file
    def parse(arg,force_encoding=nil)

      xml=open(arg,force_encoding)
      @products=[]

      root = xml.root

      case root
        when tag_match("ONIXMessage")
          root.children.each do |e|
            case e
              when tag_match("Header")
                e.children.each do |t|
                  case t
                    when tag_match("Sender")
                      @sender=Sender.from_xml(t)
                    when tag_match("SentDateTime")
                      tm=t.text
                      @sent_date_time=Time.strptime(tm, "%Y%m%dT%H%M%S") rescue Time.strptime(tm, "%Y%m%dT%H%M") rescue Time.strptime(tm, "%Y%m%d") rescue nil
                    when tag_match("DefaultLanguageOfText")
                      @default_language_of_text=LanguageCode.from_code(t.text)
                    when tag_match("DefaultCurrencyCode")
                      @default_currency_code=t.text
                  end
                end
              when tag_match("Product")
                product=Product.from_xml(e)
                product.default_language_of_text=@default_language_of_text
                product.default_currency_code=@default_currency_code
                @products << product

            end
          end

        when tag_match("Product")
          product=Product.from_xml(xml.root)
          product.default_language_of_text=@default_language_of_text
          product.default_currency_code=@default_currency_code
          @products << product
      end

      init_vault

    end
  end
end
