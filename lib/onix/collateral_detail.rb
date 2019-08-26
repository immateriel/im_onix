module ONIX
  class TextContent < SubsetDSL
    element "TextType", :subset
    element "ContentAudience", :subset
    element "Text", :text
    element "TextAuthor", :text
    element "SourceTitle", :text

    scope :description, lambda { human_code_match(:text_type, "Description")}
    scope :short_description, lambda { human_code_match(:text_type, "ShortDescriptionannotation")}

    # shortcuts
    def type
      @text_type
    end
  end

  class CollateralDetail < SubsetDSL
    elements "TextContent", :subset
    elements "SupportingResource", :subset

    def description
      desc_contents=@text_contents.description + @text_contents.short_description
      if desc_contents.length > 0
        desc_contents.first.text
      else
        nil
      end
    end

    # largest frontcover if multiple
    def frontcover_resource
      fc=@supporting_resources.front_cover
      if fc.length > 0
        if fc.length > 1
          best_found=fc.select{|c| c.versions.last and c.versions.last.image_width}.sort { |c1, c2| c2.versions.last.image_width <=> c1.versions.last.image_width }.first
          if best_found
            # we take larger one
            best_found.versions.last
          else
            # we try first that is not gif
            fc.select{|sr| not sr.versions.last.file_format=="Gif"}.first.versions.last
          end
        else
          fc.first.versions.last
        end
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

    def frontcover_mimetype
      if self.frontcover_resource
        self.frontcover_resource.file_mimetype
      end
    end

    def epub_sample_resource
      es=@supporting_resources.sample_content.select{|sr| sr.versions.last and sr.versions.last.file_format=="Epub"}.first
      if es
        es.versions.last
      end
    end

    def audio_sample_url
      audio = @supporting_resources.audio.first.versions.last
      if audio
        audio.links.first.strip
      end
    end

    def epub_sample_url
      if self.epub_sample_resource
        self.epub_sample_resource.links.first.strip
      end
    end

    def epub_sample_last_updated
      if self.epub_sample_resource
        self.epub_sample_resource.last_updated
      end
    end

    def epub_sample_mimetype
      if self.epub_sample_resource
        self.epub_sample_resource.file_mimetype
      end
    end

  end
end
