require 'onix/helper'
require 'onix/code'
require 'onix/entity'
require 'onix/descriptive_detail'
require 'onix/publishing_detail'
require 'onix/collateral_detail'
require 'onix/related_material'
require 'onix/supporting_resource'
require 'onix/subject'
require 'onix/contributor'
require 'onix/product_supply'
require 'onix/territory'
require 'onix/error'

module ONIX
  class Product < Subset
    attr_accessor :notification_type,
                  :identifiers,
                  :related_material,
                  :descriptive_detail,
                  :publishing_detail,
                  :collateral_detail,
                  :product_supplies

    include EanMethods

    def initialize
      @identifiers=[]
      @product_supplies=[]
    end

    def contributors
      @descriptive_detail.contributors
    end

    def title
      @descriptive_detail.title
    end

    def subtitle
      @descriptive_detail.subtitle
    end

    def description
      if @collateral_detail
        @collateral_detail.description
      else
        nil
      end
    end

    def language_of_text
      @descriptive_detail.language_of_text
    end

    def bisac_categories
      @descriptive_detail.bisac_categories
    end

    ## digital

    def protection_type
      @descriptive_detail.protection_type
    end

    def digital?
      @descriptive_detail.digital?
    end

    def bundle?
        @descriptive_detail.bundle?
    end

    def parts
      @descriptive_detail.parts
    end

    def filesize
      @descriptive_detail.filesize
    end

    def file_format
      @descriptive_detail.file_format
    end

    def file_description
      @descriptive_detail.file_description
    end

    def raw_file_description
      if @descriptive_detail.file_description
        @descriptive_detail.file_description.gsub(/\s+/," ").strip
      else
        nil
      end
    end

    def pages
      @descriptive_detail.pages
    end

    def raw_description
      if self.description
        self.description.gsub(/\s+/," ").strip
      else
        nil
      end
    end

    def publisher
      if @publishing_detail
        @publishing_detail.publisher
      else
        nil
      end
    end

    def publisher_name
      if self.publisher
        self.publisher.name
      else
        nil
      end
    end

    def publisher_gln
      if self.publisher
        self.publisher.gln
      end
    end

    def imprint
      if @publishing_detail
        @publishing_detail.publisher
      else
        nil
      end
    end

    def imprint_name
      if self.imprint
        self.imprint.name
      else
        nil
      end
    end

    def imprint_gln
      if self.imprint
        self.imprint.gln
      end
    end

    def distributors
      @product_supplies.map{|ps| ps.distributors}.flatten.uniq{|d| d.name}
    end

    def distributor
      if self.distributors.length > 0
      if self.distributors.length==1
        self.distributors.first
      else
        raise ExpectsOneButHasSeveral, self.distributors.map(&:name)
      end
      else
        nil
      end
    end

    def distributor_name
      if self.distributor
        self.distributor.name
      else
        nil
      end
    end

    def paper_linking
      if @related_material
        @related_material.paper_linking
      end
    end

    def publication_date
      if @publishing_detail
        @publishing_detail.publication_date
      end
    end

    def countries_rights
      countries=[]
      if @publishing_detail
        countries+=@publishing_detail.sales_rights.map{|sr| sr.territory.countries}.flatten.uniq
      end

      if @product_supplies
        countries+=@product_supplies.map{|ps| ps.markets.map{|m| m.territory.countries}.flatten}.flatten.uniq
      end

      countries.uniq
    end

    # flattened prices/supplies
    def supplies
      supplies=[]

      # add territories if missing
      if @product_supplies
        @product_supplies.each do |ps|
          # without unavailable
          ps.supply_details.each do |sd|
            sd.prices.each do |p|
              supply={}
              supply[:available]=sd.available?
              supply[:availability_date]=sd.availability_date
              supply[:price]=p.amount
              supply[:including_tax]=p.including_tax?
              if !p.territory or p.territory.countries.length==0
                supply[:territory]=Territory.new
                if ps.markets
                  supply[:territory]=ps.markets.map{|m| m.territory.countries}.flatten.uniq
                end
                if supply[:territory].length==0
                  if @publishing_detail
                    supply[:territory]=self.countries_rights
                  end
                end
              else
                supply[:territory]=p.territory.countries
              end
              supply[:from_date]=p.from_date
              supply[:until_date]=p.until_date
              supply[:currency]=p.currency
              supplies << supply
            end
          end
        end
      end

      # merge territories
      grouped_supplies={}
      supplies.each do |supply|
        pr_key="#{supply[:including_tax]}#{supply[:from_date]}#{supply[:until_date]}#{supply[:currency]}#{supply[:amount]}"
        grouped_supplies[pr_key]||=supply
        grouped_supplies[pr_key][:territory]+=supply[:territory]
        grouped_supplies[pr_key][:territory].uniq!

      end

      supplies=grouped_supplies.to_a.map{|h| h.last}

      grouped_supplies={}
      supplies.each do |supply|
        pr_key="#{supply[:including_tax]}#{supply[:currency]}#{supply[:territory].join(',')}"
        grouped_supplies[pr_key]||=[]
        grouped_supplies[pr_key] << supply
      end

      # render prices sequentially with dates
      grouped_supplies.each do |ksup, supply|
        if supply.length > 1
#          puts "MULTIPRICES"
          global_price=supply.select{|p| not p[:from_date] and not p[:until_date]}
#          pp global_price
          global_price=global_price.first
          if global_price
#            puts "FOUND GLOBAL"
            supply.each do |p|
              if p!=global_price
                if p[:from_date]
                  global_price[:until_date]=p[:from_date]
                end

                if p[:until_date]
                  np=global_price.dup
                  np[:from_date]=p[:until_date]
                  supply << np
                end

              end
            end
          else
            # remove explicit from date
            explicit_from=supply.select{|p| p[:from_date] and not supply.select{|sp| sp[:until_date]==p[:from_date]}.first}.first
            if explicit_from
              explicit_from[:from_date]=nil
            end
          end
        end
      end

      supplies=grouped_supplies.to_a.map{|h| h.last}.flatten

      supplies
    end


    def supplies_including_tax
      self.supplies.select{|p| p[:including_tax]}
    end

    def current_price_amount_for(currency)
      sup=supplies_including_tax.select{|p| p[:currency]==currency}.select{|p|
        (!p[:from_date] or p[:from_date].to_time <= Time.now) and
            (!p[:until_date] or p[:until_date].to_time > Time.now)
      }.first
      if sup
        sup[:price]
      else
        nil
      end
    end

    def available_product_supplies
      @product_supplies.select{|ps| ps.available?}
    end

    def available?
      self.available_product_supplies.length > 0 and not self.delete?
    end


    def delete?
      self.notification_type.human=="Delete"
    end

    def parse(p)
      if p.at("./NotificationType")
        @notification_type=NotificationType.from_code(p.at("./NotificationType").text)
      end

      @identifiers=Identifier.parse_identifiers(p,"Product")

      # RelatedMaterial

      related=p.at("./RelatedMaterial")
      if related
        @related_material=RelatedMaterial.from_xml(related)
      end

      # DescriptiveDetail
      descriptive=p.at("./DescriptiveDetail")
      if descriptive
        @descriptive_detail=DescriptiveDetail.from_xml(descriptive)
      end

      # CollateralDetail
      collateral=p.at("./CollateralDetail")
      if collateral
        @collateral_detail=CollateralDetail.from_xml(collateral)
      end

      # PublishingDetail
      publishing = p.at("./PublishingDetail")
      if publishing
        @publishing_detail=PublishingDetail.from_xml(publishing)
      end

      # ProductSupply
      p.search("./ProductSupply").each do |ps|
        @product_supplies << ProductSupply.from_xml(ps)
      end
    end
  end
end