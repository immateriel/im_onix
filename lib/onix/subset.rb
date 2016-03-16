module ONIX
  TagNameMatcher = Struct.new(:tag_name) do
    def ===(target)
      if target.element?
        name=target.name
        if target.attribute("refname")
          name=target.attribute("refname").to_s
        end
        name.casecmp(tag_name) == 0
      else
        false
      end

    end
  end

  class Subset
    # instanciate Subset form Nokogiri::XML::Node
    def self.from_xml(n)
      o=self.new
      o.parse(n)
      o
    end

    # parse Nokogiri::XML::Node
    def parse(n)
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