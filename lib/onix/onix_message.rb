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

require 'onix/onix21'

module ONIX
  class Sender < SubsetDSL
    include GlnMethods

    elements "SenderIdentifier", :subset
    element "SenderName", :text
    element "ContactName", :text
    element "EmailAddress", :text

    # shortcuts
    def identifiers
      @sender_identifiers
    end

    def name
      @sender_name
    end
  end

  class Addressee < SubsetDSL
    include GlnMethods

    elements "AddresseeIdentifier", :subset
    element "AddresseeName", :text

    # shortcuts
    def identifiers
      @addressee_identifiers
    end

    def name
      @addressee_name
    end
  end

  class Header < SubsetDSL
    include GlnMethods

    element "FromCompany", :text
    element "DefaultLanguageOfText", :subset
  end

  class ONIXMessage < Subset
    attr_accessor :sender, :adressee, :sent_date_time,
                  :default_language_of_text, :default_currency_code,
                  :products, :release
    attr_reader :raw_header_xml, :header

    def initialize
      @products=[]
      @vault={}
    end

    def vault
      @vault
    end

    def vault= v
      @vault = v
    end

    # merge another message in this one
    # current object erase other values
    def merge!(other)
      @products+=other.products
      @products=@products.uniq { |p| p.ean }
      init_vault
      self
    end

    # keep products for which block return true
    def select! &block
      @products.select! { |p| block.call(p) }
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
        product.related.each do |rel|
          rel.identifiers.each do |ident|
            if @vault[ident.uniq_id]
              rel.product=@vault[ident.uniq_id]
            end
          end
        end

        product.parts.each do |prt|
          prt.identifiers.each do |ident|
            if @vault[ident.uniq_id]
              prt.product=@vault[ident.uniq_id]
            end
          end
        end
      end
    end

    # open with arg detection
    def open(arg, force_encoding=nil)
      data=ONIX::Helper.arg_to_data(arg)

      xml=nil
      if force_encoding
        xml=Nokogiri::XML.parse(data, nil, force_encoding)
      else
        xml=Nokogiri::XML.parse(data)
      end

      xml.remove_namespaces!
      xml
    end

    # parse filename or file
    def parse(arg, force_encoding=nil, force_release=nil)
      xml=open(arg, force_encoding)
      @products=[]

      root = xml.root
      case root
        when tag_match("ONIXMessage")
          @release=root["release"]
          if force_release
            @release=force_release.to_s
          end
          root.elements.each do |e|
            case e
              when tag_match("Header")
                @raw_header_xml = e
                if @release =~ /^3.0/
                  @header = Header.parse(e)
                  e.elements.each do |t|
                    case t
                    when tag_match("Sender")
                      @sender=Sender.parse(t)
                    when tag_match("Addressee")
                      @addressee=Addressee.parse(t)
                    when tag_match("SentDateTime")
                      tm=t.text
                      @sent_date_time=Time.strptime(tm, "%Y%m%dT%H%M%S") rescue Time.strptime(tm, "%Y%m%dT%H%M") rescue Time.strptime(tm, "%Y%m%d") rescue nil
                    when tag_match("DefaultLanguageOfText")
                      @default_language_of_text=LanguageCode.parse(t)
                    when tag_match("DefaultCurrencyCode")
                      @default_currency_code=t.text
                    else
                      unsupported(t)
                    end
                  end
                else
                  @header = ONIX21::Header.parse(e)
                end
              when tag_match("Product")
                product=nil
                if @release =~ /^3.0/
                  product=Product.parse(e)
                else
                  product=ONIX21::Product.parse(e)
                end
                product.default_language_of_text=@default_language_of_text
                product.default_currency_code=@default_currency_code
                @products << product
            end
          end

        when tag_match("Product")
          product=Product.parse(xml.root)
          product.default_language_of_text=@default_language_of_text
          product.default_currency_code=@default_currency_code
          @products << product
      end

      init_vault
    end
  end
end
