# -*- encoding : utf-8 -*-
require 'yaml'

module ONIX
  class InvalidCodeAlias < StandardError
  end

  module CodeHelper
    def parse(n)
      @code = n.text
      @human = self.class.hash[n.text]
    end

    # Humanized string code
    def human
      @human
    end

    # ONIX code
    def onix
      @code
    end
  end

  class Code < Subset
    # @!attribute code
    #   @return [String] code as defined in ONIX documentation codelist
    attr_accessor :code
    # @!attribute human
    #   @return [String] humanized string (eg: "Digital watermarking" become DigitalWatermarking, "PDF" become Pdf, "BISAC Subject Heading" become BisacSubjectHeading, etc)
    attr_accessor :human

    include CodeHelper

    # create Code from ONIX code
    # @param [String] code ONIX code
    # @return [Code]
    def self.from_code(code)
      obj = self.new
      obj.code = code
      obj.human = self.hash[code]
      obj
    end

    # create Code from human readable code
    # @param [String] human human readable code
    # @return [Code]
    def self.from_human(human)
      obj = self.new
      obj.human = human
      obj.code = self.hash.key(human)
      unless obj.code
        raise InvalidCodeAlias, [self.to_s, human]
      end
      obj
    end

    private

    def self.hash
      {}
    end
  end

  class CodeFromYaml < Code
    def self.hash
      @hash ||= YAML.load(File.open(File.dirname(__FILE__) + "/../../data/codelists/codelist-#{self.code_ident}.yml"))[:codelist]
    end

    def self.list
      self.hash.to_a.map { |h| h.first }
    end

    def self.code_ident
      nil
    end

    def self.code_identifier code
      define_singleton_method :code_ident do
        return code
      end
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
    code_identifier 1
  end

  class ProductComposition < CodeFromYaml
    code_identifier 2
  end

  class RecordSourceType < CodeFromYaml
    code_identifier 3
  end

  class ProductIDType < CodeFromYaml
    code_identifier 5
  end

  class ProductClassificationType < CodeFromYaml
    code_identifier 9
  end

  class TradeCategory < CodeFromYaml
    code_identifier 12
  end

  class CollectionIDType < CodeFromYaml
    code_identifier 13
  end

  class TitleType < CodeFromYaml
    code_identifier 15
  end

  class WorkIDType < CodeFromYaml
    code_identifier 16
  end

  class ContributorRole < CodeFromYaml
    code_identifier 17
  end

  class NameType < CodeFromYaml
    code_identifier 18
  end

  class UnnamedPersons < CodeFromYaml
    code_identifier 19
  end

  class ConferenceRole < CodeFromYaml
    code_identifier 20
  end

  class EditionType < CodeFromYaml
    code_identifier 21
  end

  class LanguageRole < CodeFromYaml
    code_identifier 22
  end

  class ExtentType < CodeFromYaml
    code_identifier 23
  end

  class ExtentUnit < CodeFromYaml
    code_identifier 24
  end

  class AncillaryContentType < CodeFromYaml
    code_identifier 25
  end

  class SubjectSchemeIdentifier < CodeFromYaml
    code_identifier 27
  end

  class AudienceCode < CodeFromYaml
    code_identifier 28
  end

  class AudienceCodeType < CodeFromYaml
    code_identifier 29
  end

  class AudienceRangeQualifier < CodeFromYaml
    code_identifier 30
  end

  class AudienceRangePrecision < CodeFromYaml
    code_identifier 31
  end

  class ComplexitySchemeIdentifier < CodeFromYaml
    code_identifier 32
  end

  class PrizeCode < CodeFromYaml
    code_identifier 41
  end

  class TextItemType < CodeFromYaml
    code_identifier 42
  end

  class TextItemIDType < CodeFromYaml
    code_identifier 43
  end

  class IDType < CodeFromYaml
    code_identifier 44
  end

  class SenderIDType < IDType
  end

  class AddresseeIDType < IDType
  end

  class RecordSourceIDType < IDType
  end

  class PublisherIDType < IDType
  end

  class ImprintIDType < IDType
  end

  class NameIDType < IDType
  end

  class NameIDType < IDType
  end

  class ProductContactIDType < IDType
  end

  class PublishingRole < CodeFromYaml
    code_identifier 45
  end

  class SalesRightsType < CodeFromYaml
    code_identifier 46
  end

  class MeasureType < CodeFromYaml
    code_identifier 48
  end

  class RegionCode < CodeFromYaml
    code_identifier 49
  end

  class MeasureUnitCode < CodeFromYaml
    code_identifier 50
  end

  class ProductRelationCode < CodeFromYaml
    code_identifier 51
  end

  class ReturnsCodeType < CodeFromYaml
    code_identifier 53
  end

  class DateFormat < CodeFromYaml
    code_identifier 55
  end

  class UnpricedItemType < CodeFromYaml
    code_identifier 57
  end

  class PriceType < CodeFromYaml
    code_identifier 58
  end

  class PriceQualifier < CodeFromYaml
    code_identifier 59
  end

  class PricePer < CodeFromYaml
    code_identifier 60
  end

  class PriceStatus < CodeFromYaml
    code_identifier 61
  end

  class TaxRateCode < CodeFromYaml
    code_identifier 62
  end

  class PublishingStatus < CodeFromYaml
    code_identifier 64
  end

  class ProductAvailability < CodeFromYaml
    code_identifier 65
  end

  class MarketPublishingStatus < CodeFromYaml
    code_identifier 68
  end

  class AgentRole < CodeFromYaml
    code_identifier 69
  end

  class StockQuantityCodeType < CodeFromYaml
    code_identifier 70
  end

  class SalesRestrictionType < CodeFromYaml
    code_identifier 71
  end

  class ThesisType < CodeFromYaml
    code_identifier 72
  end

  class WebsiteRole < CodeFromYaml
    code_identifier 73
  end

  class LanguageCode < CodeFromYaml
    code_identifier 74
  end

  class ProductFormFeatureType < CodeFromYaml
    code_identifier 79
  end

  class ProductPackaging < CodeFromYaml
    code_identifier 80
  end

  class ProductContentType < CodeFromYaml
    code_identifier 81
  end

  class BibleContents < CodeFromYaml
    code_identifier 82
  end

  class BibleVersion < CodeFromYaml
    code_identifier 83
  end

  class StudyBibleType < CodeFromYaml
    code_identifier 84
  end

  class BiblePurpose < CodeFromYaml
    code_identifier 85
  end

  class BibleTextOrganization < CodeFromYaml
    code_identifier 86
  end

  class BibleReferenceLocation < CodeFromYaml
    code_identifier 87
  end

  class ReligiousTextIdentifier < CodeFromYaml
    code_identifier 88
  end

  class ReligiousTextFeatureType < CodeFromYaml
    code_identifier 89
  end

  class ReligiousTextFeatureCode < CodeFromYaml
    code_identifier 90
  end

  class CountryCode < CodeFromYaml
    code_identifier 91
  end

  class SupplierIDType < CodeFromYaml
    code_identifier 92
  end

  class AgentIDType < CodeFromYaml
    code_identifier 92
  end

  class SupplierRole < CodeFromYaml
    code_identifier 93
  end

  class BibleTextFeature < CodeFromYaml
    code_identifier 97
  end

  class DiscountCodeType < CodeFromYaml
    code_identifier 100
  end

  class SalesOutletIDType < CodeFromYaml
    code_identifier 102
  end

  class ScriptCode < CodeFromYaml
    code_identifier 121
  end

  class BarcodeType < CodeFromYaml
    code_identifier 141
  end

  class PositionOnProduct < CodeFromYaml
    code_identifier 142
  end

  class EpubTechnicalProtection < CodeFromYaml
    code_identifier 144
  end

  class EpubUsageType < CodeFromYaml
    code_identifier 145
  end

  class EpubUsageStatus < CodeFromYaml
    code_identifier 146
  end

  class EpubUsageUnit < CodeFromYaml
    code_identifier 147
  end

  class CollectionType < CodeFromYaml
    code_identifier 148
  end

  class TitleElementLevel < CodeFromYaml
    code_identifier 149
  end

  class ProductForm < CodeFromYaml
    code_identifier 150
  end

  class ContributorPlaceRelator < CodeFromYaml
    code_identifier 151
  end

  class Illustrated < CodeFromYaml
    code_identifier 152
  end

  class TextType < CodeFromYaml
    code_identifier 153
  end

  class ContentAudience < CodeFromYaml
    code_identifier 154
  end

  class ContentDateRole < CodeFromYaml
    code_identifier 155
  end

  class CitedContentType < CodeFromYaml
    code_identifier 156
  end

  class SourceType < CodeFromYaml
    code_identifier 157
  end

  class ResourceContentType < CodeFromYaml
    code_identifier 158
  end

  class ResourceMode < CodeFromYaml
    code_identifier 159
  end

  class ResourceFeatureType < CodeFromYaml
    code_identifier 160
  end

  class ResourceForm < CodeFromYaml
    code_identifier 161
  end

  class ResourceVersionFeatureType < CodeFromYaml
    code_identifier 162
  end

  class MarketDateRole < CodeFromYaml
    code_identifier 163
  end

  class PublishingDateRole < CodeFromYaml
    code_identifier 163
  end

  class WorkRelationCode < CodeFromYaml
    code_identifier 164
  end

  class SupplierCodeType < CodeFromYaml
    code_identifier 165
  end

  class SupplyDateRole < CodeFromYaml
    code_identifier 166
  end

  class PriceConditionType < CodeFromYaml
    code_identifier 167
  end

  class PriceConditionQuantityType < CodeFromYaml
    code_identifier 168
  end

  class QuantityUnit < CodeFromYaml
    code_identifier 169
  end

  class DiscountType < CodeFromYaml
    code_identifier 170
  end

  class TaxType < CodeFromYaml
    code_identifier 171
  end

  class CurrencyZone < CodeFromYaml
    code_identifier 172
  end

  class PriceDateRole < CodeFromYaml
    code_identifier 173
  end

  class PrintedOnProduct < CodeFromYaml
    code_identifier 174
  end

  class ProductFormDetail < CodeFromYamlWithMime
    code_identifier 175
  end

  class ContributorDateRole < CodeFromYaml
    code_identifier 177
  end

  class SupportingResourceFileFormat < CodeFromYamlWithMime
    code_identifier 178
  end

  class PriceCodeType < CodeFromYaml
    code_identifier 179
  end

  class CollectionSequenceType < CodeFromYaml
    code_identifier 197
  end

  class ProductContactRole < CodeFromYaml
    code_identifier 198
  end

  class ReturnsCode < CodeFromYaml
    code_identifier 204
  end

  class Proximity < CodeFromYaml
    code_identifier 215
  end

  class VelocityMetric < CodeFromYaml
    code_identifier 216
  end

  class PriceIDType < CodeFromYaml
    code_identifier 217
  end

  class EpubLicenseExpressionType < CodeFromYaml
    code_identifier 218
  end

  class CopyrightType < CodeFromYaml
    code_identifier 219
  end

  class FundingIDType < CodeFromYaml
    code_identifier 228
  end

  class Gender < CodeFromYaml
    code_identifier 229
  end

  class PriceConstraintType < CodeFromYaml
    code_identifier 230
  end

  class SupplyContactRole < CodeFromYaml
    code_identifier 239
  end

  class AVItemType < CodeFromYaml
    code_identifier 240
  end

  class AVItemIDType < CodeFromYaml
    code_identifier 241
  end

  class EventIDType < CodeFromYaml
    code_identifier 244
  end

  class EventType < CodeFromYaml
    code_identifier 245
  end

  class EventStatus < CodeFromYaml
    code_identifier 246
  end

  class OccurrenceDateRole < CodeFromYaml
    code_identifier 247
  end
end
