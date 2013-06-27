require 'onix/subset'

module ONIX
  class Contributor < Subset
    attr_accessor :name_before_key, :key_names, :person_name, :role, :biography_note, :sequence_number

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

    def biography
      @biography_note
    end

    def raw_biography
      if self.biography
        self.biography.gsub(/\s+/," ")
      else
        nil
      end
    end

    def parse(c)
      if c.at("./SequenceNumber")
        @sequence_number=c.at("./SequenceNumber").text.to_i
      end

        if c.at("./NamesBeforeKey")
        @name_before_key = c.at("./NamesBeforeKey").text
      end
      if c.at("./KeyNames")
        @key_names =  c.at("./KeyNames").text
      end

      if c.at("./PersonName")
        @person_name = c.at("./PersonName").text
      end

      @role=ContributorRole.from_code(c.at("./ContributorRole").text)

      if c.at("./BiographicalNote")
        @biography_note=c.at("./BiographicalNote").text.strip
      end
    end
  end
end