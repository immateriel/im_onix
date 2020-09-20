require 'onix/subset'
require 'onix/website'

module ONIX
  class Contributor < SubsetDSL
    element "SequenceNumber", :integer
    element "ContributorRole", :subset, :shortcut => :role
    elements "NameIdentifier", :subset, :shortcut => :identifiers
    element "PersonName", :text
    element "PersonNameInverted", :text
    element "NamesBeforeKey", :text, :shortcut => :name_before_key
    element "KeyNames", :text
    element "CorporateName", :text
    element "CorporateNameInverted", :text
    element "BiographicalNote", :text
    elements "Website", :subset
    element "ContributorPlace", :subset, :shortcut => :place
    elements "ContributorDate", :subset, :shortcut => :dates

    # @!group High level
    # flatten person name (firstname lastname)
    # @return [String]
    def name
      return @person_name if @person_name

      if @key_names
        if @names_before_key
          return "#{@names_before_key} #{@key_names}"
        else
          return @key_names
        end
      end

      @corporate_name
    end

    # inverted flatten person name
    # @return [String]
    def inverted_name
      @person_name_inverted || @corporate_name_inverted
    end

    # biography string with HTML
    # @return [String]
    def biography
      @biographical_note
    end

    # raw biography string without HTML
    # @return [String]
    def raw_biography
      if self.biography
        Helper.strip_html(self.biography).gsub(/\s+/, " ")
      end
    end

    # date of birth
    # @return [Time]
    def birth_date
      if contributor_date = @contributor_dates.find { |d| d.role.human == "DateOfBirth" }
        contributor_date.date.to_time
      end
    end

    # date of death
    # @return [Time]
    def death_date
      if contributor_date = @contributor_dates.find { |d| d.role.human == "DateOfDeath" }
        contributor_date.date.to_time
      end
    end

    # @!endgroup
  end

  class ContributorPlace < SubsetDSL
    element "ContributorPlaceRelator", :subset
    element "CountryCode", :subset

    def relator
      @contributor_place_relator
    end

    def country_code
      @country_code.code
    end
  end
end
