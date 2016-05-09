module ONIX
  class Short
    def self.names
      @shortnames||=YAML.load(File.open(File.dirname(__FILE__) + "/../../data/shortnames.yml"))
    end
  end

  TagNameMatcher = Struct.new(:tag_name) do
    def ===(target)
      if target.element?
        name=target.name
        name.casecmp(tag_name) == 0 or Short.names[name] == tag_name
      else
        false
      end
    end
  end

  class Subset
    # instanciate Subset form Nokogiri::XML::Element
    def self.parse(n)
      o=self.new
      o.parse(n)
      o
    end

    # parse Nokogiri::XML::Element
    def parse(n)
    end

    def unsupported(tag)
#      raise SubsetUnsupported,tag.name
      puts "SubsetUnsupported: #{self.class}##{tag.name} (#{Short.names[tag.name]})"
    end

    def tag_match(v)
      TagNameMatcher.new(v)
    end

    def self.tag_match(v)
      TagNameMatcher.new(v)
    end

    #    def inspect
    #      vars = instance_variables.collect { |v| v.to_s << "=#{instance_variable_get(v).inspect}"}.join(",\n ")
    #      "#<#{self.class} #{vars}>"
    #    end
  end
end