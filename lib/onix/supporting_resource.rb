module ONIX

  class ContentDate < Subset
    attr_accessor :date, :role
    def parse(n)
      n.children.each do |t|
        case t.name
          when "ContentDateRole"
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
      @type=ResourceVersionFeatureType.from_code(f.at_xpath("./ResourceVersionFeatureType").text)

      @value=Helper.text_at(f,"./FeatureValue")

      if @type.human=="FileFormat"
        @value=SupportingResourceFileFormat.from_code(@value)
      end

      f.xpath("./FeatureNote").each do |fn|
        @notes << fn.text
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

    def last_updated_utc
      if self.last_updated_content_date
        self.last_updated_content_date.date.date.to_time.strftime('%Y%m%dT%H%M%S%z')
      end
    end

      def parse(n)
        n.children.each do |t|
          case t.name
            when "ResourceForm"
              @form=ResourceForm.from_code(t.text)
            when "ResourceLink"
              @links << t.text.strip
            when "ContentDate"
              @content_dates << ContentDate.from_xml(t)
            when "ResourceVersionFeature"
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
        case t.name
          when "ResourceFeatureType"
            @type=ResourceFeatureType.from_code(t.text)
          when "FeatureValue"
            @value=t.text
          when "FeatureNote"
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

    def caption_feature
      @features.select{|i| i.type.human=="Caption"}.first
    end

    def caption
      if self.caption_feature
        self.caption_feature.value
      end
    end

    def parse(n)
      n.children.each do |t|
        case t.name
          when "ResourceContentType"
            @type=ResourceContentType.from_code(t.text)
          when "ContentAudience"
            @target_audience=ContentAudience.from_code(t.text)
          when "ResourceMode"
            @mode=ResourceMode.from_code(t.text)
          when "ResourceVersion"
            @versions << ResourceVersion.from_xml(t)
          when "ResourceFeature"
            @features << ResourceFeature.from_xml(t)
        end
      end

    end
  end
end