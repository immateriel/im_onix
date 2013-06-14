module ONIX

  class ContentDate < Subset
    attr_accessor :date, :role
    def parse(d)
      @date=Helper.parse_date(d)
      @role=ContentDateRole.from_code(Helper.mandatory_text_at(d,"ContentDateRole"))
    end
  end

  class ResourceVersionFeature < Subset
    attr_accessor :type, :value, :notes

    def initialize
      @notes=[]
    end

    def parse(f)
      @type=ResourceVersionFeatureType.from_code(f.at("./ResourceVersionFeatureType").text)

      @value=Helper.text_at(f,"./FeatureValue")

      if @type.human=="FileFormat"
        @value=SupportingResourceFileFormat.from_code(@value)
      end

      f.search("./FeatureNote").each do |fn|
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
      if @form.human=="DownloadableFile"
        if file_format_feature
          file_format_feature.value.human
        end
      end
    end


      def parse(rv)
      @form=ResourceForm.from_code(Helper.mandatory_text_at(rv,"./ResourceForm"))
          rv.search("./ResourceLink").each do |l|
            @links << l.text
          end
      rv.search("./ContentDate").each do |d|
        @content_dates << ContentDate.from_xml(d)
      end

      rv.search("./ResourceVersionFeature").each do |rvf|
        @features << ResourceVersionFeature.from_xml(rvf)
      end

    end
  end

  class ResourceFeature < Subset
    attr_accessor :type, :value, :notes

    def initialize
      @notes=[]
    end
    def parse(f)
      @type=ResourceFeatureType.from_code(f.at("./ResourceFeatureType").text)

      @value=Helper.text_at(f,"./FeatureValue")

      f.search("./FeatureNote").each do |fn|
        @notes << fn.text
      end

    end
  end

  class SupportingResource < Subset
    attr_accessor :type, :mode, :target_audience, :versions, :features

    def initialize
      @versions=[]
      @features=[]
    end
    def parse(sr)
      @type=ResourceContentType.from_code(Helper.mandatory_text_at(sr,"./ResourceContentType"))
      @target_audience=ContentAudience.from_code(Helper.mandatory_text_at(sr,"./ContentAudience"))
      @mode=ResourceMode.from_code(Helper.mandatory_text_at(sr,"./ResourceMode"))
      sr.search("./ResourceVersion").each do |rv|
        @versions << ResourceVersion.from_xml(rv)
      end
      sr.search("./ResourceFeature").each do |rf|
        @features << ResourceFeature.from_xml(rf)
      end

    end
  end
end