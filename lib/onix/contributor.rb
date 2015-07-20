require 'onix/subset'

module ONIX
  class Contributor < Subset
    attr_accessor :name_before_key, :key_names, :person_name, :inverted_name, :role, :biography_note, :sequence_number

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
    # inverted flatten person name (lastname firstname)
    def inverted_name
      if @inverted_name
        @inverted_name
      else
        if @key_names
          if @name_before_key
            "#{@key_names}, #{@name_before_key}"
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
      n.children.each do |t|
        case t.name
          when "SequenceNumber"
            @sequence_number=t.text.to_i
          when "NamesBeforeKey"
            @name_before_key=t.text
          when "KeyNames"
            @key_names=t.text
          when "PersonName"
            @person_name=t.text
          when "PersonNameInverted"
            @inverted_name=t.text
          when "BiographicalNote"
            @biography_note=t.text.strip
          when "ContributorRole"
            @role=ContributorRole.from_code(t.text)
        end
      end
    end

  end
end
