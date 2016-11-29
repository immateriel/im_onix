require 'onix/subset'
require 'onix/website'

module ONIX
  class Contributor < SubsetDSL
    element "NamesBeforeKey", :text
    element "KeyNames", :text
    element "PersonName", :text
    element "PersonNameInverted", :text
    element "ContributorRole", :subset
    element "ContributorPlace", :subset
    element "BiographicalNote", :text
    element "SequenceNumber", :integer
    elements "Website", :subset
    elements "NameIdentifier", :subset

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
