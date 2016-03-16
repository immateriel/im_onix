module ONIX

  class ContentDate < Subset
    attr_accessor :date, :role
    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("ContentDateRole")
            @role=ContentDateRole.from_code(t.text)
        end
      end
      @date=OnixDate.from_xml(n)

    end
  end

  class ResourceVersionFeature < Subset
    attr_accessor :type, :value, :notes

    def initialize
      @notes=[]
    end

    def parse(f)
      f.children.each do |fn|
        case fn
          when tag_match("ResourceVersionFeatureType")
            @type = ResourceVersionFeatureType.from_code(fn.text)
          when tag_match("FeatureNote")
            @notes << fn.text
        end
      end

      @value=Helper.text_at(f,"./FeatureValue")

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
      @features.select{|f| f.type.human=="FileFormat"}.first
    end

    def file_format
      if ["DownloadableFile","LinkableResource"].include?(@form.human)
        if file_format_feature
          file_format_feature.value.human
        end
      end
    end

    def file_mimetype
      if ["DownloadableFile","LinkableResource"].include?(@form.human)
        if file_format_feature
          file_format_feature.value.mimetype
        end
      end
    end

    def image_width_feature
      @features.select{|i| i.type.human=="ImageWidthInPixels"}.first
    end

    def image_height_feature
      @features.select{|i| i.type.human=="ImageHeightInPixels"}.first
    end

    def md5_hash_feature
      @features.select{|i| i.type.human=="Md5HashValue"}.first
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
      @content_dates.select{|cd| cd.role.human=="LastUpdated"}.first
    end

    def last_updated
      if self.last_updated_content_date
        self.last_updated_content_date.date.date
      end
    end

      def parse(n)
        n.children.each do |t|
          case t
            when tag_match("ResourceForm")
              @form=ResourceForm.from_code(t.text)
            when tag_match("ResourceLink")
              @links << t.text.strip
            when tag_match("ContentDate")
              @content_dates << ContentDate.from_xml(t)
            when tag_match("ResourceVersionFeature")
              @features << ResourceVersionFeature.from_xml(t)

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
      n.children.each do |t|
        case t
          when tag_match("ResourceFeatureType")
            @type=ResourceFeatureType.from_code(t.text)
          when tag_match("FeatureValue")
            @value=t.text
          when tag_match("FeatureNote")
            @notes << t.text

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
      n.children.each do |t|
        case t
          when tag_match("ResourceContentType")
            @type=ResourceContentType.from_code(t.text)
          when tag_match("ContentAudience")
            @target_audience=ContentAudience.from_code(t.text)
          when tag_match("ResourceMode")
            @mode=ResourceMode.from_code(t.text)
          when tag_match("ResourceVersion")
            @versions << ResourceVersion.from_xml(t)
          when tag_match("ResourceFeature")
            @features << ResourceFeature.from_xml(t)
        end
      end

    end
  end
end