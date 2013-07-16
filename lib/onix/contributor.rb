require 'onix/subset'

module ONIX
  class Contributor < Subset
    attr_accessor :name_before_key, :key_names, :person_name, :role, :biography_note, :sequence_number

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

    def parse(c)
      if c.at_xpath("./SequenceNumber")
        @sequence_number=c.at_xpath("./SequenceNumber").text.to_i
      end

        if c.at_xpath("./NamesBeforeKey")
        @name_before_key = c.at_xpath("./NamesBeforeKey").text
      end
      if c.at_xpath("./KeyNames")
        @key_names =  c.at_xpath("./KeyNames").text
      end

      if c.at_xpath("./PersonName")
        @person_name = c.at_xpath("./PersonName").text
      end

      @role=ContributorRole.from_code(c.at_xpath("./ContributorRole").text)

      if c.at_xpath("./BiographicalNote")
        @biography_note=c.at_xpath("./BiographicalNote").text.strip
      end
    end
  end
end