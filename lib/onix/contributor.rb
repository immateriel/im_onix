require 'onix/subset'
require 'onix/website'
require 'onix/professional_affiliation'
require 'onix/contributor_place'

module ONIX
  class Contributor < SubsetDSL
    element "SequenceNumber", :integer, :cardinality => 0..1
    element "NameType",:integer, :cardinality => 0..1
    element "ContributorRole", :subset, :shortcut => :role, :cardinality => 1..n
    elements "FromLanguage", :subset, :klass => "LanguageCode", :cardinality => 0..n
    elements "ToLanguage", :subset, :klass => "LanguageCode", :cardinality => 0..n

    # element "NameType", :subset, :cardinality => 0..1


    elements "NameIdentifier", :subset, :shortcut => :identifiers, :cardinality => 0..n
    element "PersonName", :text, :cardinality => 0..1
    element "PersonNameInverted", :text, :cardinality => 0..1
    element "TitlesBeforeNames", :text, :cardinality => 0..1
    element "NamesBeforeKey", :text, :shortcut => :name_before_key, :cardinality => 0..1
    element "PrefixToKey", :text, :cardinality => 0..1
    element "KeyNames", :text, :cardinality => 0..1
    element "NamesAfterKey", :text, :cardinality => 0..1
    element "SuffixToKey", :text, :cardinality => 0..1
    element "LettersAfterNames", :text, :cardinality => 0..1
    element "TitlesAfterNames", :text, :cardinality => 0..1

    # element "Gender", :subset, :cardinality => 0..1


    element "CorporateName", :text, :cardinality => 0..1
    element "CorporateNameInverted", :text, :cardinality => 0..1

    # element "UnnamedPersons", :subset, :cardinality => 0..1
    # elements "AlternativeName", :subset, :cardinality => 0..n


    elements "ContributorDate", :subset, :shortcut => :dates, :cardinality => 0..n
    elements "ProfessionalAffiliation", :subset, :cardinality => 0..n
    elements "Prize", :subset, :cardinality => 0..n
    elements "BiographicalNote", :text, :shortcut => :biographies, :cardinality => 0..n
    elements "Website", :subset, :cardinality => 0..n
    elements "ContributorDescription", :text, :cardinality => 0..n
    elements "ContributorPlace", :subset, :shortcut => :places, :cardinality => 0..n

    # @!group Shortcuts

    # @return [ContributorPlace]
    def place
      self.places.first
    end

    # !@endgroup

    # @!group High level
    # flatten person name (firstname lastname)
    # @return [String]
    def name
      return person_name if person_name

      if key_names
        if names_before_key
          return "#{names_before_key} #{key_names}"
        else
          return key_names
        end
      end

      corporate_name
    end

    # inverted flatten person name
    # @return [String]
    def inverted_name
      person_name_inverted || corporate_name_inverted
    end

    # biography string with HTML
    # @return [String]
    def biography
      self.biographies.first
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
end
