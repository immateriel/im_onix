require 'onix/text_content'

module ONIX
  class CollateralDetail < SubsetDSL
    elements "TextContent", :subset
    elements "SupportingResource", :subset

    # @!group High level

    # product description string including HTML
    # @return [String]
    def description
      desc_contents = @text_contents.description + @text_contents.short_description
      if desc_contents.length > 0
        desc_contents.first.text
      end
    end

    def frontcover_resource
      fc = @supporting_resources.front_cover
      if fc.length > 0
        if fc.length > 1
          best_found = fc.select { |c| c.versions.last and c.versions.last.image_width }.sort { |c1, c2| c2.versions.last.image_width <=> c1.versions.last.image_width }.first
          if best_found
            # we take larger one
            best_found.versions.last
          else
            # we try first that is not gif
            fc.select { |sr| not sr.versions.last.file_format == "Gif" }.first.versions.last
          end
        else
          fc.first.versions.last
        end
      end
    end

    # product larger front cover URL string
    # @return [String]
    def frontcover_url
      if self.frontcover_resource
        self.frontcover_resource.links.first.strip
      end
    end

    # product larger front cover last updated date
    def frontcover_last_updated
      if self.frontcover_resource
        self.frontcover_resource.last_updated
      end
    end

    # product larger front cover mimetype
    def frontcover_mimetype
      if self.frontcover_resource
        self.frontcover_resource.file_mimetype
      end
    end

    def epub_sample_resource
      es = @supporting_resources.sample_content.select { |sr| sr.versions.last and sr.versions.last.file_format == "Epub" }.first
      if es
        es.versions.last
      end
    end

    # Epub sample URL
    # @return [String]
    def epub_sample_url
      if self.epub_sample_resource
        self.epub_sample_resource.links.first.strip
      end
    end

    # Epub sample last updated
    # @return [Date]
    def epub_sample_last_updated
      if self.epub_sample_resource
        self.epub_sample_resource.last_updated
      end
    end

    # Epub sample mimetype
    # @return [String]
    def epub_sample_mimetype
      if self.epub_sample_resource
        self.epub_sample_resource.file_mimetype
      end
    end

    # @!endgroup
  end
end