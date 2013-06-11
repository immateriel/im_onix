module ONIX

  class ContentDate < Subset
    attr_accessor :date, :role
    def parse(d)
      @date=Helper.parse_date(d)
      @role=ContentDateRole.from_code(Helper.mandatory_text_at(d,"ContentDateRole"))
    end
  end
  class ResourceVersion < Subset
    attr_accessor :form, :links, :content_dates

    def initialize
      @links=[]
      @content_dates=[]
    end

    def parse(rv)
      @form=ResourceForm.from_code(Helper.mandatory_text_at(rv,"./ResourceForm"))
          rv.search("./ResourceLink").each do |l|
            @links << l.text
          end
      rv.search("./ContentDate").each do |d|
        @content_dates << ContentDate.from_xml(d)
      end
    end
  end

  class SupportingResource < Subset
    attr_accessor :type, :mode, :target_audience, :versions

    def initialize
      @versions=[]
    end
    def parse(sr)
      @type=ResourceContentType.from_code(Helper.mandatory_text_at(sr,"./ResourceContentType"))
      @target_audience=ContentAudience.from_code(Helper.mandatory_text_at(sr,"./ContentAudience"))
      @mode=ResourceMode.from_code(Helper.mandatory_text_at(sr,"./ResourceMode"))
      sr.search("./ResourceVersion").each do |rv|
        @versions << ResourceVersion.from_xml(rv)
      end
    end
  end
end