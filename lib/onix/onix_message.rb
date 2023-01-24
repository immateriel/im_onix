require 'nokogiri'
require 'time'

require 'onix/subset'
require 'onix/helper'
require 'onix/code'
require 'onix/header'
require 'onix/sender'
require 'onix/addressee'
require 'onix/product'

require 'onix/onix21'

module ONIX
  class ONIXMessage < SubsetDSL
    extend Forwardable
    attr_accessor :release

    element "Header", :subset, :cardinality => 1
    elements "Product", :subset, :cardinality => 0..n

    def_delegator :header, :sender
    def_delegator :header, :addressee
    def_delegator :header, :default_language_of_text
    def_delegator :header, :default_currency_code
    def_delegator :header, :sent_date_time

    def header
      @header || Header.new
    end

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
        product.default_language_of_text = self.default_language_of_text if @header
        product.default_currency_code = self.default_currency_code if @header
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
    # @param [String, File] arg
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
    # @return [Number]
    def version
      if @release
        @release.gsub(/\./, "").to_i * 10 ** (3 - @release.scan(".").length - 1)
      end
    end

    # detect ONIX version from XML tags
    # @return [String]
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

    def product_klass
      self.version >= 300 ? Product : ONIX21::Product
    end

    def get_class(name)
      if name == "Product"
        self.product_klass
      else
        super(name)
      end
    end

    # parse filename or file
    # @param [String, File] arg
    def parse(arg, force_encoding = nil, force_release = nil)
      @products = []
      xml = open(arg, force_encoding)
      root = xml.root
      set_release_from_xml(root, force_release)
      case root
      when tag_match("Product")
        @products << self.product_klass.parse(root)
      else # ONIXMessage
        super(root)
      end

      init_vault
    end
  end
end
