module ONIX
  class SalesRights < Subset
    attr_accessor :type, :territory
    def parse(sr)
      @type=SalesRightsType.from_code(Helper.mandatory_text_at(sr,"./SalesRightsType"))
      @territory=Territory.from_xml(sr.at("./Territory"))
    end
  end

  class PublishingDate < Subset
    attr_accessor :role, :date

    def parse(pd)
      @role=PublishingDateRole.from_code(pd.at("./PublishingDateRole").text)
      @date=Helper.parse_date(pd)
    end
  end

  class PublishingDetail < Subset
    attr_accessor :status, :publishers, :imprints,
                  :sales_rights,
                  :publishing_dates

    def initialize
      @sales_rights=[]
      @publishing_dates=[]
    end

    def publisher
      if @publishers.length==1
        @publishers.first
      else
        raise ExpectsOneButHasSeveral, Publisher
      end
    end

    def imprint
      if @imprints.length==1
        @imprints.first
      else
        raise ExpectsOneButHasSeveral, Imprint
      end
    end

    def publication_date
      pub=@publishing_dates.select{|pd| pd.role.human=="PublicationDate" || pd.role.human=="EmbargoDate"}.first
      if pub
        pub.date
      else
        nil
      end
    end

    def parse(publishing)

      @status=PublishingStatus.from_code(Helper.text_at(publishing,"./PublishingStatus"))

      publishing.search("./SalesRights").each do |sr|
        @sales_rights << SalesRights.from_xml(sr)
      end

      publishing.search("./PublishingDate").each do |pd|
        @publishing_dates << PublishingDate.from_xml(pd)
      end

      @imprints = Imprint.parse_entities(publishing,"./Imprint")
      @publishers=Publisher.parse_entities(publishing,"./Publisher")
    end
  end
end