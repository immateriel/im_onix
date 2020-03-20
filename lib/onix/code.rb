# -*- encoding : utf-8 -*-
require 'yaml'

module ONIX
  class Code < Subset
    # code as defined in ONIX documentation codelist
    attr_accessor :code
    # humanized string (eg: "Digital watermarking" become DigitalWatermarking, "PDF" become Pdf, "BISAC Subject Heading" become BisacSubjectHeading, etc)
    attr_accessor :human

    # create Code from string ONIX code
    def self.from_code(code)
      o=self.new
      o.code=code
      o.human=self.hash[code]
      o
    end

    # create Code from humanized string code
    def self.from_human(human)
      o=self.new
      o.human=human
      o.code=self.hash.key(human)
      o
    end

    # Humanized string code
    def human
      @human
    end

    # ONIX code
    def onix
      @code
    end

    private
    def self.hash
      {}
    end

  end

  class CodeFromYaml < Code
    def self.hash
      @hash||=YAML.load(File.open(File.dirname(__FILE__) + "/../../data/codelists/codelist-#{self.code_ident}.yml"))[:codelist]
    end

    def self.list
      self.hash.to_a.map{|h| h.first}
    end

    def self.code_ident
      nil
    end
  end

  class CodeFromYamlWithMime < CodeFromYaml
    # main formats
    def mimetype
      case self.human
        when "Epub"
          "application/epub"
        when "Pdf"
          "application/pdf"
        when "Mobipocket"
          "application/x-mobipocket-ebook"
        when "Gif"
          "image/gif"
        when "Jpeg"
          "image/jpeg"
        when "Png"
          "image/png"
      end
    end

  end

  class NotificationType < CodeFromYaml
    private
    def self.code_ident
      1
    end
  end

  class ProductComposition < CodeFromYaml
    private
    def self.code_ident
      2
    end
  end

  class ProductIDType < CodeFromYaml
    private
    def self.code_ident
      5
    end
  end

  class WorkIDType < CodeFromYaml
    private
    def self.code_ident
      16
    end
  end

  class SupplierIDType < CodeFromYaml
    private
    def self.code_ident
      92
    end
  end

  class AgentIDType < CodeFromYaml
    private
    def self.code_ident
      92
    end
  end

  class PublisherIDType < CodeFromYaml
    private
    def self.code_ident
      44
    end
  end

  class ImprintIDType < CodeFromYaml
    private
    def self.code_ident
      44
    end
  end

  class PublishingRole < CodeFromYaml
    private
    def self.code_ident
      45
    end
  end

  class SalesOutletIDType < CodeFromYaml
    private
    def self.code_ident
      102
    end
  end

  class ProductForm < CodeFromYaml
    private
    def self.code_ident
      150
    end
  end

  class EpubTechnicalProtection < CodeFromYaml
    private
    def self.code_ident
      144
    end
  end

  class TitleType < CodeFromYaml
    private
    def self.code_ident
      15
    end
  end

  class TitleElementLevel < CodeFromYaml
    private
    def self.code_ident
      149
    end
  end

  class ProductFormDetail < CodeFromYamlWithMime
    private
    def self.code_ident
      175
    end
  end

  class TextType < CodeFromYaml
    private
    def self.code_ident
      153
    end
  end

  class ContributorRole < CodeFromYaml
    private
    def self.code_ident
      17
    end
  end

  class ContributorPlaceRelator < CodeFromYaml
    private
    def self.code_ident
      151
    end
  end

  class ContributorNameIdentifierNameIDType < CodeFromYaml
    private
    def self.code_ident
      44
    end
  end

  class ContentAudience < CodeFromYaml
    private
    def self.code_ident
      154
    end
  end

  class ResourceForm < CodeFromYaml
    private
    def self.code_ident
      161
    end
  end

  class ResourceMode < CodeFromYaml
    private
    def self.code_ident
      159
    end
  end

  class ResourceContentType < CodeFromYaml
    private
    def self.code_ident
      158
    end
  end

  class ContentDateRole < CodeFromYaml
    private
    def self.code_ident
      155
    end
  end

  class ProductRelationCode < CodeFromYaml
    private
    def self.code_ident
      51
    end
  end

  class SubjectSchemeIdentifier < CodeFromYaml
    private
    def self.code_ident
      27
    end
  end

  class ProductAvailability < CodeFromYaml
    private
    def self.code_ident
      65
    end
  end

  class UnpricedItemType < CodeFromYaml
    private
    def self.code_ident
      57
    end
  end

  class PriceType < CodeFromYaml
    private
    def self.code_ident
      58
    end
  end

  class PriceQualifier < CodeFromYaml
    private
    def self.code_ident
      59
    end
  end

  class PriceDateRole < CodeFromYaml
    private
    def self.code_ident
      173
    end
  end

  class SupplyDateRole < CodeFromYaml
    private
    def self.code_ident
      166
    end
  end

  class SupplierRole < CodeFromYaml
    private
    def self.code_ident
      93
    end
  end

  class AgentRole < CodeFromYaml
    private
    def self.code_ident
      69
    end
  end

  class SalesRightsType < CodeFromYaml
    private
    def self.code_ident
      46
    end
  end

  class PublishingDateRole < CodeFromYaml
    private
    def self.code_ident
      163
    end
  end

  class PublishingStatus < CodeFromYaml
    private
    def self.code_ident
      64
    end
  end

  class WorkRelationCode < CodeFromYaml
    private
    def self.code_ident
      164
    end
  end

  class CountryCode < CodeFromYaml
    private
    def self.code_ident
      91
    end
  end

  class RegionCode < CodeFromYaml
    private
    def self.code_ident
      49
    end
  end

  class CollectionType < CodeFromYaml
    private
    def self.code_ident
      148
    end
  end

  class ExtentType < CodeFromYaml
    private
    def self.code_ident
      23
    end
  end

  class ExtentUnit < CodeFromYaml
    private
    def self.code_ident
      24
    end
  end

  class EpubUsageType < CodeFromYaml
    private
    def self.code_ident
      145
    end
  end

  class EpubUsageStatus < CodeFromYaml
    private
    def self.code_ident
      146
    end
  end

  class EpubUsageUnit < CodeFromYaml
    private
    def self.code_ident
      147
    end
  end

  class CollectionIDType < CodeFromYaml
    private
    def self.code_ident
      13
    end
  end

  class ResourceFeatureType < CodeFromYaml
    private
    def self.code_ident
      160
    end
  end

  class ResourceVersionFeatureType < CodeFromYaml
    private
    def self.code_ident
      162
    end
  end

  class SupportingResourceFileFormat < CodeFromYamlWithMime
    private
    def self.code_ident
      178
    end
  end

  class LanguageRole < CodeFromYaml
    private
    def self.code_ident
      22
    end
  end

  class LanguageCode < CodeFromYaml
    private
    def self.code_ident
      74
    end
  end

  class MarketDateRole < CodeFromYaml
    private
    def self.code_ident
      163
    end
  end

  class TaxRateCode < CodeFromYaml
    private
    def self.code_ident
      62
    end
  end

  class ProductFormFeatureType < CodeFromYaml
    private
    def self.code_ident
      79
    end
  end

  class SenderIDType < CodeFromYaml
    private
    def self.code_ident
      44
    end
  end

  class DateFormat < CodeFromYaml
    private
    def self.code_ident
      55
    end
  end

  class SalesRestrictionType < CodeFromYaml
    private
    def self.code_ident
      71
    end
  end

  class AudienceRangeQualifier < CodeFromYaml
    private
    def self.code_ident
      30
    end
  end

  class AudienceRangePrecision < CodeFromYaml
    private
    def self.code_ident
      31
    end
  end

end
