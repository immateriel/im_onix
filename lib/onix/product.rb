require 'forwardable'
require 'onix/helper'
require 'onix/code'
require 'onix/entity'
require 'onix/identifier'
require 'onix/descriptive_detail'
require 'onix/publishing_detail'
require 'onix/collateral_detail'
require 'onix/related_material'
require 'onix/supporting_resource'
require 'onix/product_supply'
require 'onix/content_detail'
require 'onix/territory'
require 'onix/error'
require 'onix/product_supplies_extractor'

module ONIX
  class Product < SubsetDSL
    extend Forwardable
    include EanMethods
    include IsbnMethods
    include ProprietaryIdMethods
    include ProductSuppliesExtractor

    element "RecordReference", :text, :cardinality => 1
    element "NotificationType", :subset, :cardinality => 1
    elements "DeletionText", :text, :cardinality => 0..n
    element "RecordSourceType", :subset, :cardinality => 0..1
    elements "RecordSourceIdentifier", :subset, :cardinality => 0..n
    element "RecordSourceName", :text, :cardinality => 0..1
    elements "ProductIdentifier", :subset, :shortcut => :identifiers, :cardinality => 0..n

    # elements "Barcode", :subset, :cardinality => 0..n


    element "DescriptiveDetail", :subset, :cardinality => 0..1
    element "CollateralDetail", :subset, :cardinality => 0..1

    # element "PromotionDetail", :subset, :cardinality => 0..1


    element "ContentDetail", :subset, :cardinality => 0..1
    element "PublishingDetail", :subset, :cardinality => 0..1
    element "RelatedMaterial", :subset, :cardinality => 0..1
    elements "ProductSupply", :subset, :cardinality => 0..n

    # default LanguageCode from ONIXMessage
    attr_accessor :default_language_of_text
    # default code from ONIXMessage
    attr_accessor :default_currency_code

    # @!group Shortcuts

    # @return (see PublishingDetail#publishers)
    def publishers
      @publishing_detail ? @publishing_detail.publishers : []
    end

    # !@endgroup

    # @!group High level

    def_delegator :descriptive_detail, :title
    def_delegator :descriptive_detail, :subtitle
    def_delegator :descriptive_detail, :edition_number
    def_delegator :descriptive_detail, :publisher_collection_title
    def_delegator :descriptive_detail, :bisac_categories # deprecated
    def_delegator :descriptive_detail, :clil_categories # deprecated
    def_delegator :descriptive_detail, :bisac_categories_codes
    def_delegator :descriptive_detail, :clil_categories_codes
    def_delegator :descriptive_detail, :keywords
    def_delegator :descriptive_detail, :protection_type
    def_delegator :descriptive_detail, :protections
    def_delegator :descriptive_detail, :drmized?
    def_delegator :descriptive_detail, :digital?
    def_delegator :descriptive_detail, :audio?
    def_delegator :descriptive_detail, :streaming?
    def_delegator :descriptive_detail, :bundle?
    def_delegator :descriptive_detail, :parts
    def_delegator :descriptive_detail, :filesize
    def_delegator :descriptive_detail, :audio_formats
    def_delegator :descriptive_detail, :audio_format
    def_delegator :descriptive_detail, :file_format
    def_delegator :descriptive_detail, :file_mimetype
    def_delegator :descriptive_detail, :file_description
    def_delegator :descriptive_detail, :reflowable?
    def_delegator :descriptive_detail, :pages
    def_delegator :descriptive_detail, :subjects
    def_delegator :descriptive_detail, :form_details
    def_delegator :descriptive_detail, :contributors

    def_delegator :collateral_detail, :description
    def_delegator :collateral_detail, :frontcover_url
    def_delegator :collateral_detail, :frontcover_last_updated
    def_delegator :collateral_detail, :frontcover_mimetype
    def_delegator :collateral_detail, :epub_sample_url
    def_delegator :collateral_detail, :epub_sample_last_updated
    def_delegator :collateral_detail, :epub_sample_mimetype

    def_delegator :publishing_detail, :publication_date
    def_delegator :publishing_detail, :embargo_date
    def_delegator :publishing_detail, :preorder_embargo_date
    def_delegator :publishing_detail, :public_announcement_date
    def_delegator :publishing_detail, :sales_restriction
    def_delegator :publishing_detail, :imprint
    def_delegator :publishing_detail, :publisher

    # @return [CollateralDetail]
    def collateral_detail
      @collateral_detail || CollateralDetail.new
    end

    # @return [DescriptiveDetail]
    def descriptive_detail
      @descriptive_detail || DescriptiveDetail.new
    end

    # @return [PublishingDetail]
    def publishing_detail
      @publishing_detail || PublishingDetail.new
    end

    # product LanguageCode of text
    # @return [String]
    def language_of_text
      @descriptive_detail.language_of_text || @default_language_of_text
    end

    # product language code string of text (eg: fre)
    # @return [String]
    def language_code_of_text
      if self.language_of_text
        self.language_of_text.code
      end
    end

    # product language name string of text (eg: French)
    # @return [String]
    def language_name_of_text
      if self.language_of_text
        self.language_of_text.human
      end
    end

    # product can be sold separately ?
    # @return [Boolean]
    def sold_separately?
      @product_supplies.map { |product_supply|
        product_supply.supply_details.map { |supply_detail| supply_detail.sold_separately? }.flatten
      }.flatten.uniq.first
    end

    # raw file description string without HTML
    # @return [String]
    def raw_file_description
      if @descriptive_detail.file_description
        Helper.strip_html(@descriptive_detail.file_description).gsub(/\s+/, " ").strip
      end
    end

    # raw book description string without HTML
    # @return [String]
    def raw_description
      if self.description
        Helper.strip_html(self.description).gsub(/\s+/, " ").strip
      end
    end

    # publisher name string, if multiple publishers are found, then they are concatenated with " / "
    # @return [String]
    def publisher_name
      if self.publishers.length > 0
        self.publishers.map { |p| p.name }.join(" / ")
      end
    end

    # publisher GLN string, nil if multiple publishers are found
    # @return [String]
    def publisher_gln
      if self.publishers.length == 1
        self.publisher.gln
      end
    end

    # imprint name string
    # @return [String]
    def imprint_name
      if self.imprint
        self.imprint.name
      end
    end

    # imprint GLN string
    # @return [String]
    def imprint_gln
      if self.imprint
        self.imprint.gln
      end
    end

    # product distributors names
    # @return [Array<String>]
    def distributors
      @product_supplies.map { |ps| ps.distributors }.flatten.uniq { |d| d.name }
    end

    # product distributor name
    # @return [String]
    def distributor
      if self.distributors.length > 0
        if self.distributors.length == 1
          self.distributors.first
        else
          raise ExpectsOneButHasSeveral, self.distributors.map(&:name)
        end
      else
        nil
      end
    end

    # product distributor name string
    # @return [String]
    def distributor_name
      if self.distributor
        self.distributor.name
      end
    end

    # product distributor GLN string
    # @return [String]
    def distributor_gln
      if self.distributor
        self.distributor.gln
      end
    end

    # return every related subset
    # @return [Array]
    def related
      if @related_material
        (@related_material.related_products + @related_material.related_works)
      else
        []
      end
    end

    # first part RelatedProduct
    # @return [RelatedProduct]
    def part_of_product
      if @related_material
        @related_material.part_of_products.first
      end
    end

    # first paper linking RelatedProduct
    # @return [RelatedProduct]
    def print_product
      if @related_material
        @related_material.print_products.first
      end
    end

    # DEPRECATED see print_product instead
    # @return [RelatedProduct]
    def paper_linking
      self.print_product
    end

    # product countries rights string array
    # @return [Array<String>]
    def countries_rights
      countries = []
      if @publishing_detail
        countries += @publishing_detail.sales_rights.map { |sale_right| sale_right.territory.countries }.flatten.uniq
      end

      if @product_supplies
        countries += @product_supplies.map { |product_supply|
          product_supply.markets.map { |market| market.territory.countries }.flatten
        }.flatten.uniq
      end

      countries.uniq
    end

    # all images
    def illustrations
      return [] unless @collateral_detail && @collateral_detail.supporting_resources

      @collateral_detail.supporting_resources.image.map do |image_resource|
        {
            :url => image_resource.versions.last.links.first.strip,
            :type => image_resource.type.human,
            :width => image_resource.versions.last.image_width,
            :height => image_resource.versions.last.image_height,
            :caption => image_resource.caption,
            :format_code => image_resource.versions.last.file_format,
            :updated_at => image_resource.versions.last.last_updated_utc
        }
      end
    end

    # all excerpts
    def excerpts
      return [] unless @collateral_detail && @collateral_detail.supporting_resources

      @collateral_detail.supporting_resources.sample_content.human_code_match(:resource_mode, ["Text", "MultiMode"]).map do |resource|
        {
            :url => resource.versions.last.links.first.strip,
            :form => resource.versions.last.form.human,
            :md5 => resource.versions.last.md5_hash,
            :format_code => resource.versions.last.file_format,
            :updated_at => resource.versions.last.last_updated_utc
        }
      end
    end

    # available product supplies
    # @return [Array<ProductSupply>]
    def available_product_supplies
      @product_supplies.select { |product_supply| product_supply.available? }
    end

    # is product available ?
    # @return [Boolean]
    def available?
      self.available_product_supplies.length > 0 and not self.delete?
    end

    # is product available for given +country+ ?
    # @return [Boolean]
    def available_for_country?(country)
      self.supplies_for_country(country).select { |s| s[:available] }.length > 0 and self.available?
    end

    # is product price to be announced ?
    # @return [Boolean]
    def price_to_be_announced?
      unless self.product_supplies.empty? || self.product_supplies.first.supply_details.empty?
        unpriced_item_type = self.product_supplies.first.supply_details.first.unpriced_item_type
      end
      unpriced_item_type ? unpriced_item_type.human == "PriceToBeAnnounced" : false
    end

    # is product a deletion notification ?
    # @return [Boolean]
    def delete?
      self.notification_type.human == "Delete"
    end

    # List of ONIX outlets values
    # @return [Array<String>]
    def onix_outlets_values
      if @publishing_detail
        @publishing_detail.sales_rights.map { |sales_right|
          sales_right.sales_restrictions.select { |sales_restriction|
            (!sales_restriction.start_date or sales_restriction.start_date <= Date.today) and
                (!sales_restriction.end_date or sales_restriction.end_date >= Date.today)
          }.map { |sale_right|
            sale_right.sales_outlets.select { |sale_outlet|
              sale_outlet.identifier and sale_outlet.identifier.type.human == "OnixRetailSalesOutletIdCode" }.map { |sale_outlet|
              sale_outlet.identifier.value
            }
          }
        }.flatten
      else
        []
      end
    end

    # @!endgroup

    def parse(n)
      super
      parts.each do |part|
        part.part_of = self
      end
    end
  end
end
