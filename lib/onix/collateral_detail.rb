module ONIX
  class TextContent < Subset
    attr_accessor :type, :text
    def parse(txt)
      @type=TextType.from_code(txt.at("./TextType").text)
      @text=txt.at("./Text").text
    end
  end

  class CollateralDetail < Subset
    attr_accessor :text_contents, :supporting_resources

    def initialize
      @text_contents=[]
      @supporting_resources=[]
    end

    def description
      desc_contents=@text_contents.select{|tc| tc.type.human=="Description"}
      if desc_contents.length > 0
        desc_contents.first.text
      else
        nil
      end
    end

    def parse(collateral)
      collateral.search("./TextContent").each do |txt|
        @text_contents << TextContent.from_xml(txt)
      end

      collateral.search("./SupportingResource").each do |sr|
        @supporting_resources << SupportingResource.from_xml(sr)
      end
    end
  end
end