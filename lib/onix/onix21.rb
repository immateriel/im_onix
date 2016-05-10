module ONIX
  module ONIX21
    class SubsetDSL < ONIX::SubsetDSL
      def self.get_class(name)
        if ONIX::ONIX21.const_defined?(name)
          ONIX::ONIX21.const_get(name)
        else
          ONIX.const_get(name)
        end
      end
    end

    class Title < SubsetDSL
      element "TitleType", :subset
      element "TitleText", :text
      element "Subtitle", :text

      def type
        @title_type
      end

      def title
        @title_text
      end
    end

    class OtherText < SubsetDSL
      element "TextTypeCode", :text
      element "TextFormat", :text
      element "Text", :text

      def type_code
        @text_type_code
      end
    end

    class Territory
      attr_accessor :countries

      def initialize(countries)
        @countries=countries
      end
    end

    class Price < SubsetDSL
      element "PriceTypeCode", :subset, :klass => "PriceType"
      element "PriceAmount", :float, {:lambda => lambda { |v| (v*100).round }}
      element "DiscountCoded", :subset
      element "CurrencyCode", :text
      elements "CountryCode", :text

      def amount
        @price_amount
      end

      def currency
        @currency_code
      end

      def including_tax?
        if @price_type_code.human =~/IncludingTax/
          true
        else
          false
        end
      end

      def from_date
        nil
      end

      def until_date
        nil
      end

      def territory
        Territory.new(@country_codes)
      end
    end

    class SupplyDetail < SubsetDSL
      element "AvailabilityCode", :text
      element "ProductAvailability", :text
      element "OnSaleDate", :text, {:lambda => lambda { |v| Date.strptime(v, "%Y%m%d") }}
      elements "Price", :subset

      def availability_date
        @on_sale_date
      end

      def available?
        @product_availability=="20"
      end
    end

    class RelatedProduct < SubsetDSL
      include EanMethods
      include ProprietaryIdMethods

      element "RelationCode", :text
      elements "ProductIdentifier", :subset

      def identifiers
        @product_identifiers
      end

      def code
        @relation_code
      end
    end

    class Product < SubsetDSL
      include EanMethods
      include ProprietaryIdMethods

      element "RecordReference", :text
      elements "ProductIdentifier", :subset
      element "NotificationType", :subset
      element "RecordSourceName", :text
      elements "Title", :subset
      elements "ProductSupply", :subset

      elements "Contributor", :subset
      elements "Extent", :subset
      elements "Language", :subset

      elements "Publisher", :subset
      elements "Imprint", :subset

      element "ProductForm", :text

      elements "OtherText", :subset
      elements "SalesRights", :subset, {:pluralize => false}

      elements "BASICMainSubject", :text

      element "PublishingStatus", :text
      element "PublicationDate", :text, {:lambda => lambda { |v| Date.strptime(v, "%Y%m%d") }}

      elements "RelatedProduct", :subset

      elements "SupplyDetail", :subset

      element "EpubType", :text
      element "EpubTypeDescription", :text
      element "EpubFormat", :text
      element "EpubTypeNote", :text

      # shortcuts
      def identifiers
        @product_identifiers
      end

      # default LanguageCode from ONIXMessage
      attr_accessor :default_language_of_text
      # default code from ONIXMessage
      attr_accessor :default_currency_code

      def title
        product_title.title
      end

      # :category: High level
      # product subtitle string
      def subtitle
        product_title.subtitle
      end

      def product_title
        @titles.select { |td| td.type.human=~/DistinctiveTitle/ }.first
      end

      def bisac_categories_codes
        @basic_main_subjects
      end

      # TODO
      def clil_categories_codes
        []
      end

      # TODO
      def keywords
        []
      end

      # doesn't apply
      def onix_outlets_values
        []
      end

      # product LanguageCode of text
      def language_of_text
        lang=nil
        l=@languages.select { |l| l.role.human=="LanguageOfText" }.first
        if l
          lang=l.code
        end
        lang || @default_language_of_text
      end

      def language_code_of_text
        if self.language_of_text
          self.language_of_text.code
        end
      end

      def language_name_of_text
        if self.language_of_text
          self.language_of_text.human
        end
      end

      def publisher_name
        if @publishers.first
          @publishers.first.name
        end
      end

      def imprint_name
        if @imprints.first
          @imprints.first.name
        end
      end

      # doesn't apply
      def sold_separately?
        true
      end

      def description
        desc_contents=@other_texts.select { |tc| tc.type_code=="01" } + @other_texts.select { |tc| tc.type_code=="13" }
        if desc_contents.length > 0
          desc_contents.first.text
        else
          nil
        end
      end

      def raw_description
        if self.description
          Helper.strip_html(self.description).gsub(/\s+/, " ").strip
        else
          nil
        end
      end

      def supplies
        supplies=[]

        # add territories if missing
        @supply_details.each do |sd|
          sd.prices.each do |p|
            supply={}
            supply[:available]=sd.available?
            supply[:availability_date]=sd.availability_date

            supply[:price]=p.amount
            supply[:including_tax]=p.including_tax?
            if !p.territory or p.territory.countries.length==0
              supply[:territory]=[]
              # TODO sales_rights here
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

            unless supply[:availability_date]
              if @publishing_detail
                supply[:availability_date]=@publishing_detail.publication_date
              end
            end

            supplies << supply
          end
        end

        grouped_supplies={}
        supplies.each do |supply|
          pr_key="#{supply[:available]}_#{supply[:including_tax]}_#{supply[:currency]}_#{supply[:territory].join('_')}"
          grouped_supplies[pr_key]||=[]
          grouped_supplies[pr_key] << supply
        end

        # render prices sequentially with dates
        grouped_supplies.each do |ksup, supply|
          if supply.length > 1
            global_price=supply.select { |p| not p[:from_date] and not p[:until_date] }
            global_price=global_price.first

            if global_price
              new_supply = []
              supply.each do |p|
                if p!=global_price
                  if p[:from_date]
                    global_price[:until_date]=p[:from_date]
                  end

                  if p[:until_date]
                    np=global_price.dup
                    np[:from_date]=p[:until_date]
                    np[:until_date]=nil
                    new_supply << np
                  end
                end
              end

              grouped_supplies[ksup] += new_supply

            else
              # remove explicit from date
              explicit_from=supply.select { |p| p[:from_date] and not supply.select { |sp| sp[:until_date] and sp[:until_date]<=p[:from_date] }.first }.first
              if explicit_from
                explicit_from[:from_date]=nil
              end
            end


          else
            supply.each do |s|
              if s[:from_date] and s[:availability_date] and s[:from_date] >= s[:availability_date]
                s[:availability_date]=s[:from_date]
              end
              s[:from_date]=nil

            end
          end
        end

        # merge by territories
        grouped_territories_supplies={}
        grouped_supplies.each do |ksup, supply|
          fsupply=supply.first
          pr_key="#{fsupply[:available]}_#{fsupply[:including_tax]}_#{fsupply[:currency]}"
          supply.each do |s|
            pr_key+="_#{s[:price]}_#{s[:from_date]}_#{s[:until_date]}"
          end
          grouped_territories_supplies[pr_key]||=[]
          grouped_territories_supplies[pr_key] << supply
        end

        supplies=[]

        grouped_territories_supplies.each do |ksup, supply|
          fsupply=supply.first.first
          supplies << {:including_tax => fsupply[:including_tax], :currency => fsupply[:currency],
                       :territory => supply.map { |fs| fs.map { |s| s[:territory] } }.flatten.uniq,
                       :available => fsupply[:available],
                       :availability_date => fsupply[:availability_date],
                       :prices => supply.first.map { |s|

                         s[:amount]=s[:price]
                         s.delete(:price)
                         s.delete(:available)
                         s.delete(:currency)
                         s.delete(:availability_date)
                         s.delete(:including_tax)
                         s.delete(:territory)
                         s
                       }}
        end

        supplies
      end

      def supplies_including_tax
        self.supplies.select { |p| p[:including_tax] }
      end

      # :category: High level
      # flattened supplies only excluding taxes
      def supplies_excluding_tax
        self.supplies.select { |p| not p[:including_tax] }
      end

      # :category: High level
      # flattened supplies with default tax (excluding tax for US and CA, including otherwise)
      def supplies_with_default_tax
        self.supplies_including_tax + self.supplies_excluding_tax.select { |s| ["CAD", "USD"].include?(s[:currency]) }
      end

      # TODO
      def current_price_amount_for(currency, country)
      end

      # doesn't apply
      def bundle?
        false
      end

      def digital?
        @product_form=="DG"
      end

      def available?
        @supply_details.select { |sd| sd.available? }.length > 0
      end

      def pages
        nil
      end

      def distributor_name
        nil
      end

      # TODO
      def publisher_collection_title
        nil
      end

      def file_format
        case @epub_type
          when "029"
            "Epub"
          when "002"
            "Pdf"
          else
            nil
        end
      end

      def file_description
        @epub_type_description
      end

      def raw_file_description
        file_description
      end

      # doesn't apply
      def filesize
        nil
      end

      # doesn't apply
      def protection_type
        nil
      end

      def frontcover_url
        nil
      end

      def epub_sample_url
        nil
      end

      def print_product
        @related_products.select { |rp| rp.code=="13" }.first
      end

      def method_missing(method)
        puts "WARN #{method} not found"
      end

    end
  end
end