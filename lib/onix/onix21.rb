module ONIX
  module ONIX21
    class ShortToRef
      def self.names
        @shortnames||=YAML.load(File.open(File.dirname(__FILE__) + "/../../data/onix21/shortnames.yml"))
      end
    end

    class RefToShort
      def self.names
        @refnames||=ShortToRef.names.invert
      end
    end

    class SubsetDSL < ONIX::SubsetDSL
      def self.short_to_ref(name)
        ONIX::ONIX21::ShortToRef.names[name]
      end
      def self.ref_to_short(name)
        ONIX::ONIX21::RefToShort.names[name]
      end

      def self.get_class(name)
        if ONIX::ONIX21.const_defined?(name,false)
          ONIX::ONIX21.const_get(name)
        else
          ONIX.const_get(name)
        end
      end
    end

    # ONIX 2.1 codes

    class CodeFromYaml < Code
      def self.hash
        @hash||=YAML.load(File.open(File.dirname(__FILE__) + "/../../data/onix21/codelists/codelist-#{self.code_ident}.yml"))[:codelist]
      end

      def self.list
        self.hash.to_a.map{|h| h.first}
      end

      def self.code_ident
        nil
      end
    end

    class EpubType < CodeFromYaml
      private
      def self.code_ident
        10
      end
    end

    class TextTypeCode < CodeFromYaml
      private
      def self.code_ident
        33
      end
    end

    class MediaFileTypeCode < CodeFromYaml
      private
      def self.code_ident
        38
      end
    end

    class MediaFileFormatCode < CodeFromYaml
      private
      def self.code_ident
        36
      end
    end

    class MediaFileLinkTypeCode < CodeFromYaml
      private
      def self.code_ident
        37
      end
    end

    # ONIX 2.1 subset

    class Title < SubsetDSL
      element "TitleType", :subset
      element "TitleText", :text
      element "TitlePrefix", :text
      element "TitleWithoutPrefix", :text
      element "AbbreviatedLength", :integer
      element "Subtitle", :text

      def type
        @title_type
      end

      def title
        @title_text
      end
    end

    class OtherText < SubsetDSL
      element "TextTypeCode", :subset
      element "TextFormat", :text
      element "Text", :text

      def type
        @text_type_code
      end
    end

    class MediaFile < SubsetDSL
      element "MediaFileTypeCode", :subset
      element "MediaFileFormatCode", :subset
      element "MediaFileLinkTypeCode", :subset
      element "MediaFileLink", :text

      def type
        @media_file_type_code
      end

      def format
        @media_file_format_code
      end

      def link_type
        @media_file_link_type_code
      end

      def link
        @media_file_link
      end
    end

    class Territory
      attr_accessor :countries

      def initialize(countries)
        @countries=countries
      end

      def +v
        Territory.new((@countries + v.countries).uniq)
      end

      def -v
        Territory.new((@countries - v.countries).uniq)
      end
    end

    class Price < SubsetDSL
      element "PriceTypeCode", :subset, :klass => "PriceType"
      element "PriceAmount", :float, {:lambda => lambda { |v| (v*100).round }}
      element "PriceQualifier", :subset
      element "DiscountCoded", :subset
      element "CurrencyCode", :text
      elements "CountryCode", :text
      element "PriceEffectiveFrom", :text
      element "PriceEffectiveUntil", :text

      def amount
        @price_amount
      end

      def currency
        @currency_code
      end

      def qualifier
        @price_qualifier
      end

      def including_tax?
        if @price_type_code.human =~/IncludingTax/
          true
        else
          false
        end
      end

      def from_date
        if @price_effective_from
          Date.strptime(@price_effective_from,"%Y%m%d")
        end
      end

      def until_date
        if @price_effective_until
          Date.strptime(@price_effective_until,"%Y%m%d")
        end
      end

      def territory
        Territory.new(@country_codes)
      end

      def tax
        nil
      end
    end


    class Supplier
      attr_accessor :name
      attr_accessor :role

      def initialize(name,role)
        @name = name
        @role = role
      end

      def identifiers
        []
      end

      def websites
        []
      end
    end

    class SupplyDetail < SubsetDSL
      element "SupplierName", :text
      element "TelephoneNumber", :text
      element "SupplierRole", :text

      element "AvailabilityCode", :text
      element "ProductAvailability", :text
      element "OnSaleDate", :text, {:lambda => lambda { |v| Date.strptime(v, "%Y%m%d") }}
      elements "Price", :subset

      def availability_date
        @on_sale_date
      end

      def available?
        @product_availability=="20" or @availability_code == "IP"
      end

      def suppliers
        [Supplier.new(self.supplier_name,self.supplier_role)]
      end
    end

    class SalesRights < SubsetDSL
      element "SalesRightsType", :text
      element "RightsCountry", :text

      def not_for_sale?
        ["03","04","05","06"].include?(@sales_rights_type)
      end

      def territory
        Territory.new(@rights_country.split(" "))
      end
    end

    class NotForSale < SubsetDSL
      element "RightsCountry", :text

      def territory
        Territory.new(@rights_country.split(" "))
      end
    end

    class RelatedProduct < SubsetDSL
      include EanMethods
      include ProprietaryIdMethods

      element "RelationCode", :text
      elements "ProductIdentifier", :subset

      def product=v
      end

      def identifiers
        @product_identifiers
      end

      def code
        @relation_code
      end
    end

    class MainSubject < SubsetDSL
      element "SubjectCode", :text
      element "SubjectHeadingText", :text
      element "MainSubjectSchemeIdentifier", :subset, :klass=>"SubjectSchemeIdentifier"
      element "SubjectSchemeName", :text
      element "SubjectSchemeVersion", :text

      # shortcuts
      def code
        @subject_code
      end

      def heading_text
        @subject_heading_text
      end

      def scheme_identifier
        @main_subject_scheme_identifier
      end

      def scheme_name
        @subject_scheme_name
      end

      def scheme_version
        @subject_scheme_version
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
      element "ContributorStatement", :text

      elements "Extent", :subset
      elements "Language", :subset
      elements "MediaFile", :subset

      element "NumberOfPages", :text

      elements "Publisher", :subset
      elements "Imprint", :subset

      element "ProductForm", :text

      elements "OtherText", :subset

      elements "SalesRights", :subset, {:pluralize => false}
      elements "NotForSale", :subset

      element "BASICMainSubject", :text
      elements "MainSubject", :subset
      elements "Subject", :subset

      element "PublishingStatus", :text
      element "PublicationDate", :text, {:lambda => lambda { |v| Date.strptime(v, "%Y%m%d") }}

      elements "RelatedProduct", :subset

      elements "SupplyDetail", :subset

      element "EpubType", :subset
      element "EpubTypeDescription", :text
      element "EpubFormat", :text
      element "EpubTypeNote", :text

      element "EditionNumber", :integer
      element "NoEdition", :ignore
      element "NoSeries", :ignore

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
        cats=[]
        if @basic_main_subject
          cats << @basic_main_subject
        end
        cats+=(@main_subjects + @subjects).select { |s| s.scheme_identifier.human=="BisacSubjectHeading" }.map{|s| s.code}
        cats
      end

      def clil_categories_codes
        (@main_subjects + @subjects).select { |s| s.scheme_identifier.human=="Clil" }.map{|s| s.code}
      end

      def keywords
        kws=(@main_subjects + @subjects).select { |s| s.scheme_identifier.human=="Keywords" }.map { |kw| kw.heading_text }.compact
        kws.map { |kw| kw.split(/;|,|\n/) }.flatten.map { |kw| kw.strip }
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
        desc_contents=@other_texts.select{|tc| tc.type.human=="MainDescription"} + @other_texts.select{|tc| tc.type.human=="LongDescription"} + @other_texts.select{|tc| tc.type.human=="ShortDescriptionannotation"}
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

      def product_supplies
        [self]
      end

      def countries
        territory=Territory.new(CountryCode.list)
        @sales_rights.each do |sr|
          if sr.not_for_sale?
            territory=territory-sr.territory
          else
            territory=territory+sr.territory
          end
        end

        @not_for_sales.each do |sr|
          territory=territory-sr.territory
        end

        territory.countries
      end

      def availability_date
        nil
      end

      def embargo_date
        nil
      end

      def preorder_embargo_date
        nil
      end

      def public_announcement_date
        nil
      end

      include ProductSuppliesExtractor

      def related
        @related_products
      end

      # doesn't apply
      def parts
        []
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

      def available_for_country?(country)
        self.supplies_for_country(country).select{|s| s[:available]}.length > 0 and self.available?
      end

      def pages
        if @number_of_pages
          @number_of_pages.to_i
        end
      end

      def edition_number
        @edition_number
      end

      def distributor_name
        nil
      end

      def frontcover_url
        fc=@media_files.select { |mf| mf.media_file_type_code.human=="ImageFrontCover" && mf.media_file_link_type_code.human=="Url"}
        if fc.length > 0
          fc.first.link
        else
          nil
        end
      end

      # TODO
      def publisher_collection_title
        nil
      end

      def file_format
        @epub_type.human
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

      def epub_sample_url
        nil
      end

      def print_product
        @related_products.select { |rp| rp.code=="13" }.first
      end

      # DEPRECATED see print_product instead
      def paper_linking
        self.print_product
      end

      def publisher_gln
        nil
      end

      def method_missing(method)
        raise "WARN #{method} not found"
      end

    end
  end
end
