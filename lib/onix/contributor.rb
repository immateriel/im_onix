require 'onix/subset'
require 'onix/website'

module ONIX
  class Contributor < SubsetDSL
    element "SequenceNumber", :integer
    element "ContributorRole", :subset
    elements "NameIdentifier", :subset

    element "PersonName", :text
    element "PersonNameInverted", :text

    element "NamesBeforeKey", :text
    element "KeyNames", :text

    element "BiographicalNote", :text
    elements "Website", :subset
    element "ContributorPlace", :subset

    elements "ContributorDate", :subset

    def role
      @contributor_role
    end

    def identifiers
      @name_identifiers
    end

    def place
      @contributor_place
    end

    def name_before_key
      @names_before_key
    end

    def dates
      @contributor_dates
    end

    # :category: High level
    # flatten person name (firstname lastname)
    def name
      if @person_name
        @person_name
      else
        if @key_names
          if @names_before_key
            "#{@names_before_key} #{@key_names}"
          else
            @key_names
          end
        end
      end
    end

    # :category: High level
    # inverted flatten person name
    def inverted_name
      @person_name_inverted
    end

    # :category: High level
    # biography string with HTML
    def biography
      @biographical_note
    end

    # :category: High level
    # raw biography string without HTML
    def raw_biography
      if self.biography
        Helper.strip_html(self.biography).gsub(/\s+/, " ")
      else
        nil
      end
    end

    # :category: High level
    # date of birth
    def birth_date
      if contributor_date = @contributor_dates.find { |d| d.role.human == "DateOfBirth" }
        contributor_date.date.to_time
      else
        nil
      end
    end

    # :category: High level
    # date of death
    def death_date
      if contributor_date = @contributor_dates.find { |d| d.role.human == "DateOfDeath" }
        contributor_date.date.to_time
      else
        nil
      end
    end
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
