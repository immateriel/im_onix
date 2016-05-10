require 'onix/sales_rights'
module ONIX
  class PublishingDate < OnixDate
    attr_accessor :role

    def parse(n)
      super
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
    end
  end

  class PublishingDetail < SubsetDSL
    element "PublishingStatus", :subset
    elements "SalesRights", :subset, {:pluralize=>false}
    element "ROWSalesRightsType", :subset, {:klass=>"SalesRightsType"}
    elements "PublishingDate", :subset
    elements "Publisher", :subset
    element "CityOfPublication", :text
    element "CountryOfPublication", :text
    elements "Imprint", :subset

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
        pub.date
      else
        nil
      end
    end

    def status
      @publising_status
    end

    def city
      @city_of_publication
    end

    def country
      @country_of_publication
    end

  end
end