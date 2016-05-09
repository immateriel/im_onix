module ONIX

  class SalesOutlet < Subset
    attr_accessor :identifier, :name
    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("SalesOutletName")
            @name = t.text
          when tag_match("SalesOutletIdentifier")
            @identifier = Identifier.parse_identifier(t, "SalesOutlet")
          else
            unsupported(t)
        end
      end
    end
  end

  class SalesRestriction < Subset
    attr_accessor :type, :sales_outlets, :note, :start_date, :end_date

    def initialize
      @sales_outlets=[]
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("SalesRestrictionType")
            @type = SalesRestrictionType.parse(t)
          when tag_match("SalesOutlet")
            @sales_outlets << SalesOutlet.parse(t)
          when tag_match("SalesRestrictionNote")
            @note = t.text
          when tag_match("StartDate")
            fmt=t["dateformat"] || "00"
            @start_date=ONIX::Helper.to_date(fmt,t.text)
          when tag_match("EndDate")
            fmt=t["dateformat"] || "00"
            @end_date=ONIX::Helper.to_date(fmt,t.text)
          else
            unsupported(t)
        end
      end
    end

  end

  class SalesRights < Subset
    attr_accessor :type, :territory, :sales_restrictions

    def initialize
      @sales_restrictions=[]
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("SalesRightsType")
            @type=SalesRightsType.parse(t)
          when tag_match("Territory")
            @territory=Territory.parse(t)
          when tag_match("SalesRestriction")
            @sales_restrictions << SalesRestriction.parse(t)
          else
            unsupported(t)
        end
      end
    end
  end

  class PublishingDate < Subset
    attr_accessor :role, :date

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("PublishingDateRole")
            @role=PublishingDateRole.parse(t)
          when tag_match("Date")
            # via OnixDate
          when tag_match("DateFormat")
            # via OnixDate
          else
            unsupported(t)
        end
      end

      @date=OnixDate.parse(n)

    end
  end

  class PublishingDetail < Subset
    attr_accessor :status, :publishers, :imprints,
                  :sales_rights,
                  :publishing_dates,
                  :city,
                  :country

    def initialize
      @sales_rights=[]
      @publishing_dates=[]
      @publishers=[]
      @imprints=[]
    end

    def publisher
      main_publishers = @publishers.select { |p| p.role.human=="Publisher" }
      return nil if main_publishers.empty?
      if main_publishers.length == 1
        main_publishers.first
      else
        raise ExpectsOneButHasSeveral, Publisher
      end
    end

    def imprint
      if @imprints.length > 0
        if @imprints.length==1
          @imprints.first
        else
          raise ExpectsOneButHasSeveral, Imprint
        end
      else
        nil
      end
    end

    def publication_date
      pub=@publishing_dates.select{|pd| pd.role.human=="PublicationDate" or pd.role.human=="PublicationDateOfPrintCounterpart" or pd.role.human=="EmbargoDate"}.first
      if pub
        pub.date.date
      else
        nil
      end
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("PublishingStatus")
            @status=PublishingStatus.parse(t)
          when tag_match("SalesRights")
            @sales_rights << SalesRights.parse(t)
          when tag_match("ROWSalesRightsType")
            @row_sales_rights_type=SalesRightsType.parse(t)
          when tag_match("PublishingDate")
            @publishing_dates << PublishingDate.parse(t)
          when tag_match("Publisher")
            @publishers << Publisher.parse(t)
          when tag_match("CityOfPublication")
            @city = t.text
          when tag_match("CountryOfPublication")
            @country = t.text
          when tag_match("Imprint")
            @imprints << Imprint.parse(t)
          else
            unsupported(t)
        end
      end
    end
  end
end