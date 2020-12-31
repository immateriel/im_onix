require 'onix/sales_rights'
require 'onix/date'
module ONIX
  class PublishingDetail < SubsetDSL
    elements "Imprint", :subset
    elements "Publisher", :subset
    element "CityOfPublication", :text, :shortcut => :city
    element "CountryOfPublication", :text, :shortcut => :country
    element "PublishingStatus", :subset, :shortcut => :status
    elements "PublishingDate", :subset
    elements "SalesRights", :subset, :pluralize => false
    element "ROWSalesRightsType", :subset, :klass => "SalesRightsType"
    element "SalesRestriction", :subset

    # @!group High level

    def publisher
      main_publishers = @publishers.select { |p| p.role.human == "Publisher" }
      return nil if main_publishers.empty?
      if main_publishers.length == 1
        main_publishers.first
      else
        raise ExpectsOneButHasSeveral, main_publishers.map(&:name)
      end
    end

    def imprint
      if @imprints.length > 0
        if @imprints.length == 1
          @imprints.first
        else
          raise ExpectsOneButHasSeveral, @imprints.map(&:name)
        end
      end
    end

    # date of publication
    def publication_date
      pub = @publishing_dates.publication.first
      if pub
        pub.date
      end
    end

    # date of embargo
    def embargo_date
      pub = @publishing_dates.embargo.first
      if pub
        pub.date
      end
    end

    def preorder_embargo_date
      pub = @publishing_dates.preorder_embargo.first
      if pub
        pub.date
      end
    end

    def public_announcement_date
      pub = @publishing_dates.public_announcement.first
      if pub
        pub.date
      end
    end

    # @!endgroup

  end
end
