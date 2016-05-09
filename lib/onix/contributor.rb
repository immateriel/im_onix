require 'onix/subset'

module ONIX
  class Contributor < Subset
    attr_accessor :name_before_key, :key_names, :person_name, :person_name_inverted, :role,
                  :biography_note, :sequence_number, :website, :identifiers

    def initialize
      @identifiers = []
    end

    # :category: High level
    # flatten person name (firstname lastname)
    def name
      if @person_name
        @person_name
      else
        if @key_names
          if @name_before_key
            "#{@name_before_key} #{@key_names}"
          else
            @key_names
          end
        end
      end
    end

    # :category: High level
    # biography string with HTML
    def biography
      @biography_note
    end

    # :category: High level
    # raw biography string without HTML
    def raw_biography
      if self.biography
        Helper.strip_html(self.biography).gsub(/\s+/," ")
      else
        nil
      end
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("SequenceNumber")
            @sequence_number=t.text.to_i
          when tag_match("NamesBeforeKey")
            @name_before_key=t.text
          when tag_match("KeyNames")
            @key_names=t.text
          when tag_match("PersonName")
            @person_name=t.text
          when tag_match("PersonNameInverted")
            @person_name_inverted=t.text
          when tag_match("BiographicalNote")
            @biography_note=t.text.strip
          when tag_match("ContributorRole")
            @role=ContributorRole.parse(t)
          when tag_match("Website")
            @website=t.text
          when tag_match("NameIdentifier")
            @identifiers = Identifier.parse_identifier(t,"Name")
          else
            unsupported(t)
        end
      end
    end
  end
end