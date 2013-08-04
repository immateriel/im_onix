module ONIX
  class TextContent < Subset
    attr_accessor :type, :text
    def parse(n)
      n.children.each do |t|
        case t.name
          when "TextType"
            @type=TextType.from_code(t.text)
          when "Text"
            @text=t.text
        end
      end
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

    def frontcover_last_updated
      if self.frontcover_resource
          self.frontcover_resource.last_updated
      end
    end

    def epub_sample_resource
      es=@supporting_resources.select { |sr| sr.type.human=="SampleContent" }.select{|sr| sr.versions.last.file_format=="Epub"}.first
      if es
        es.versions.last
      end
    end

    def epub_sample_url
      if self.epub_sample_resource
        self.epub_sample_resource.links.first.strip
      end
    end

    def epub_sample_url_last_updated
      if self.epub_sample_url_resource
        self.epub_sample_url.last_updated
      end
    end


    def parse(n)
      n.children.each do |t|
        case t.name
          when "TextContent"
            @text_contents << TextContent.from_xml(t)
          when "SupportingResource"
            @supporting_resources << SupportingResource.from_xml(t)
        end
      end
    end
  end
end