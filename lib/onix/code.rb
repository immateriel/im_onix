# -*- encoding : utf-8 -*-

module ONIX
  class Code
    attr_accessor :code, :human

    def self.from_code(code)
      o=self.new
      o.code=code
      o.human=self.hash[code]
      o
    end

    def self.from_human(human)
      o=self.new
      o.human=human
      o.code=self.hash.key(human)
      o
    end

    def self.hash
      {}
    end

    def human
      @human
    end

    def onix
      @code
    end


  end

  class CodeFromHtml < Code

    def self.hash
      @hash||=self.parse_codelist(File.dirname(__FILE__) + "/../../data/codelists/onix-codelist-#{self.code_ident}.htm")
    end

    # from rails
    def self.rename(term)
      term.gsub(/\(|\)|\,|\-|’/,"").split(" ").map{|t| t.capitalize}.join("")
    end

    def self.list
      self.hash.to_a.map{|h| h.first}
    end

    def self.parse_codelist(codelist)
      h={}
      html=Nokogiri::HTML.parse(File.open(codelist))
      html.search("//tr").each do |tr|
#        pp tr
        td_code=tr.at("./td[1]")
        td_human=tr.at("./td[2]")
        if td_code and td_human
          h[td_code.text.strip]=self.rename(td_human.text.strip)
        end
      end
      h
    end

  end

  class NotificationType < CodeFromHtml
    def self.code_ident
      1
    end
  end

  class ProductComposition < CodeFromHtml
    def self.code_ident
      2
    end
  end

  class ProductIDType < CodeFromHtml
    def self.code_ident
      5
    end
  end

  class WorkIDType < CodeFromHtml
    def self.code_ident
      16
    end
  end

  class SupplierIDType < CodeFromHtml
    def self.code_ident
      92
    end
  end

  class AgentIDType < Code
    def self.hash
      {
          "01"=>"Proprietary",
          "06"=>"GLN"
      }
    end
  end

  class PublisherIDType < Code
    def self.hash
      {
          "01"=>"Proprietary",
          "06"=>"GLN"
      }
    end
  end

  class ImprintIDType < Code
    def self.hash
      {
          "01"=>"Proprietary",
          "06"=>"GLN"
      }
    end
  end

  class ProductForm < CodeFromHtml
    def self.code_ident
      150
    end
  end

  class EpubTechnicalProtection < Code
    def self.hash
      {
      "00"=>"None",
      "01"=>"DRM",
      "02"=>"DigitalWatermarking",
      "03"=>"AdobeDRM",
      # WTF?
      "04"=>"AppleDRM",
      "05"=>"OMADRM"
      }
    end
  end

  class TitleType < Code
    def self.hash
      {
          "00" => "Undefined",
          "01" => "DistinctiveTitle",
          "03" => "TitleInOriginalLanguage",
          "05" => "AbbreviatedTitle",
          "08" => "FormerTitle"
      }
    end
  end

  class ProductFormDetail < CodeFromHtml
    def self.code_ident
      175
    end
  end

  class TextType < CodeFromHtml
    def self.code_ident
      153
    end
  end

  class ContributorRole < CodeFromHtml
    def self.code_ident
      17
    end
  end

  class ContentAudience < CodeFromHtml
    def self.code_ident
      154
    end
  end

  class ResourceForm < CodeFromHtml
    def self.code_ident
      161
    end
  end

  class ResourceMode < CodeFromHtml
    def self.code_ident
      159
    end
  end

  class ResourceContentType < CodeFromHtml
    def self.code_ident
      158
    end
  end

  class ContentDateRole < CodeFromHtml
    def self.code_ident
      155
    end
  end

  class ProductRelationCode < CodeFromHtml
    def self.code_ident
      51
    end
  end

  class SubjectSchemeIdentifier < CodeFromHtml
    def self.code_ident
      27
    end
  end

  class ProductAvailability < CodeFromHtml
    def self.code_ident
      65
    end
  end

  class PriceType < CodeFromHtml
    def self.code_ident
      58
    end
  end

  class PriceDateRole < Code
    def self.hash
      {
          "14"=>"FromDate",
          "15"=>"UntilDate",
          "24"=>"FromUntilDate"
      }
    end
  end

  class SupplyDateRole < Code
    def self.hash
      {
          "02"=>"EmbargoDate",
          "08"=>"ExpectedAvailabilityDate"
      }
    end
  end

  class SupplierRole < CodeFromHtml
    def self.code_ident
      93
    end
  end

  class AgentRole < CodeFromHtml
    def self.code_ident
      69
    end
  end

  class SalesRightsType < CodeFromHtml
    def self.code_ident
      46
    end
  end

  class PublishingDateRole < CodeFromHtml
    def self.code_ident
      163
    end
  end

  class PublishingStatus < CodeFromHtml
    def self.code_ident
      64
    end
  end

  class WorkRelationCode < CodeFromHtml
    def self.code_ident
      164
    end
  end

  class CountryCode < CodeFromHtml
    def self.code_ident
      91
    end
  end

  class RegionCode < CodeFromHtml
    def self.code_ident
      49
    end
  end

end