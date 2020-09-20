require 'nokogiri'
require 'pp'
require 'time'
require 'benchmark'

require 'onix/subset'
require 'onix/helper'
require 'onix/code'
require 'onix/sender'
require 'onix/addressee'
require 'onix/product'

require 'onix/onix21'

module ONIX
  class ONIXMessage < Subset
    attr_accessor :sender, :adressee, :sent_date_time,
                  :default_language_of_text, :default_currency_code,
                  :products,
                  :release

    def initialize
      @products = []
      @vault = {}
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
      @products += other.products
      @products = @products.uniq { |p| p.ean }
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
      @vault = {}
      @products.each do |product|
        product.identifiers.each do |ident|
          @vault[ident.uniq_id] = product
        end
      end

      @products.each do |product|
        product.related.each do |rel|
          rel.identifiers.each do |ident|
            if @vault[ident.uniq_id]
              rel.product = @vault[ident.uniq_id]
            end
          end
        end

        product.parts.each do |prt|
          prt.identifiers.each do |ident|
            if @vault[ident.uniq_id]
              prt.product = @vault[ident.uniq_id]
            end
          end
        end
      end
    end

    # open with arg detection
    def open(arg, force_encoding = nil)
      data = ONIX::Helper.arg_to_data(arg)

      xml = nil
      if force_encoding
        xml = Nokogiri::XML.parse(data, nil, force_encoding)
      else
        xml = Nokogiri::XML.parse(data)
      end

      xml.remove_namespaces!
      xml
    end

    # release as an integer eg: 210, 300, 301
    def version
      if @release
        @release.gsub(/\./, "").to_i * 10 ** (3 - @release.scan(".").length - 1)
      end
    end

    # detect ONIX version from XML tags
    def detect_release(element)
      if element
        return "3.0" if element.search("//DescriptiveDetail").length > 0
        return "3.0" if element.search("//CollateralDetail").length > 0
        return "3.0" if element.search("//ContentDetail").length > 0
        return "3.0" if element.search("//PublishingDetail").length > 0
      end
      "2.1"
    end

    def set_release_from_xml(node, force_release)
      @release = node["release"]
      unless @release
        @release = detect_release(node)
      end
      if force_release
        @release = force_release.to_s
      end
    end

    # parse filename or file
    def parse(arg, force_encoding = nil, force_release = nil)
      xml = open(arg, force_encoding)
      @products = []
      root = xml.root
      set_release_from_xml(root, force_release)
      case root
      when tag_match("ONIXMessage")
        root.elements.each do |e|
          case e
          when tag_match("Header")
            e.elements.each do |t|
              case t
              when tag_match("Sender")
                @sender = Sender.parse(t)
              when tag_match("Addressee")
                @addressee = Addressee.parse(t)
              when tag_match("SentDateTime")
                tm = t.text
                @sent_date_time = Time.strptime(tm, "%Y%m%dT%H%M%S") rescue Time.strptime(tm, "%Y%m%dT%H%M") rescue Time.strptime(tm, "%Y%m%d") rescue nil
              when tag_match("DefaultLanguageOfText")
                @default_language_of_text = LanguageCode.parse(t)
              when tag_match("DefaultCurrencyCode")
                @default_currency_code = t.text
              else
                unsupported(t)
              end
            end
          when tag_match("Product")
            product = nil
            if self.version >= 300
              product = Product.parse(e)
            else
              product = ONIX21::Product.parse(e)
            end
            product.default_language_of_text = @default_language_of_text
            product.default_currency_code = @default_currency_code
            @products << product
          end
        end
      when tag_match("Product")
        product = nil
        if self.version >= 300
          product = Product.parse(root)
        else
          product = ONIX21::Product.parse(root)
        end
        product.default_language_of_text = @default_language_of_text
        product.default_currency_code = @default_currency_code
        @products << product
      end
      init_vault
    end
  end
end
