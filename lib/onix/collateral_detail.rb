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

    # largest frontcover if multiple
    def frontcover_resource
      fc=@supporting_resources.select { |sr| sr.type.human=="FrontCover" }
      if fc.length > 0
        if fc.length > 1
        else
          fc.first.versions.last
        end
        fc.sort { |c1, c2| c2.versions.last.image_width <=> c1.versions.last.image_width }.first.versions.last
      end
    end

    def frontcover_url
      if self.frontcover_resource
        self.frontcover_resource.links.first.strip
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