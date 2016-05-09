module ONIX

  class ContentDate < OnixDate
    attr_accessor :role

    def parse(n)
      super
      n.elements.each do |t|
        case t
          when tag_match("ContentDateRole")
            @role=ContentDateRole.parse(t)
          when tag_match("Date")
            # via OnixDate
          when tag_match("DateFormat")
            # via OnixDate
          else
            unsupported(t)
        end
      end
    end
  end

  class ResourceVersionFeature < Subset
    attr_accessor :type, :value, :notes

    def initialize
      @notes=[]
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("ResourceVersionFeatureType")
            @type = ResourceVersionFeatureType.parse(t)
          when tag_match("FeatureNote")
            @notes << t.text
          when tag_match("FeatureValue")
            @value = t.text
          else
            unsupported(t)
        end
      end

      if @type.human=="FileFormat"
        @value=SupportingResourceFileFormat.from_code(@value)
      end
    end
  end

  class ResourceVersion < Subset
    attr_accessor :form, :links, :content_dates, :features

    def initialize
      @links=[]
      @content_dates=[]
      @features=[]
    end

    def filename
      if @form.human=="DownloadableFile"
        @links.first
      end
    end

    def file_format_feature
      @features.select { |f| f.type.human=="FileFormat" }.first
    end

    def file_format
      if ["DownloadableFile", "LinkableResource"].include?(@form.human)
        if file_format_feature
          file_format_feature.value.human
        end
      end
    end

    def file_mimetype
      if ["DownloadableFile", "LinkableResource"].include?(@form.human)
        if file_format_feature
          file_format_feature.value.mimetype
        end
      end
    end

    def image_width_feature
      @features.select { |i| i.type.human=="ImageWidthInPixels" }.first
    end

    def image_height_feature
      @features.select { |i| i.type.human=="ImageHeightInPixels" }.first
    end

    def md5_hash_feature
      @features.select { |i| i.type.human=="Md5HashValue" }.first
    end

    def image_width
      if self.image_width_feature
        self.image_width_feature.value.to_i
      end
    end

    def image_height
      if self.image_height_feature
        self.image_height_feature.value.to_i
      end
    end

    def md5_hash
      if self.md5_hash
        self.md5_hash.value
      end
    end

    def last_updated_content_date
      @content_dates.select { |cd| cd.role.human=="LastUpdated" }.first
    end

    def last_updated
      if self.last_updated_content_date
        self.last_updated_content_date.date
      end
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("ResourceForm")
            @form=ResourceForm.parse(t)
          when tag_match("ResourceLink")
            @links << t.text.strip
          when tag_match("ContentDate")
            @content_dates << ContentDate.parse(t)
          when tag_match("ResourceVersionFeature")
            @features << ResourceVersionFeature.parse(t)
          else
            unsupported(t)
        end
      end
    end
  end

  class ResourceFeature < Subset
    attr_accessor :type, :value, :notes

    def initialize
      @notes=[]
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("ResourceFeatureType")
            @type=ResourceFeatureType.parse(t)
          when tag_match("FeatureValue")
            @value=t.text
          when tag_match("FeatureNote")
            @notes << t.text
          else
            unsupported(t)
        end
      end
    end
  end

  class SupportingResource < Subset
    attr_accessor :type, :mode, :target_audience, :versions, :features

    def initialize
      @versions=[]
      @features=[]
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("ResourceContentType")
            @type=ResourceContentType.parse(t)
          when tag_match("ContentAudience")
            @target_audience=ContentAudience.parse(t)
          when tag_match("ResourceMode")
            @mode=ResourceMode.parse(t)
          when tag_match("ResourceVersion")
            @versions << ResourceVersion.parse(t)
          when tag_match("ResourceFeature")
            @features << ResourceFeature.parse(t)
          else
            unsupported(t)
        end
      end
    end
  end
end