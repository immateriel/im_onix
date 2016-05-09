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
    def self.attr_accessor(*vars)
      @attributes ||= []
      @attributes.concat vars
      super(*vars)
    end

    def self.attributes
      @attributes||[]
    end

    def self.rec_attributes
      attrs=[]
      sup=self
      while(sup.respond_to?(:attributes))
        attrs+=sup.attributes
        sup=sup.superclass
      end
      attrs
    end

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
#      puts "SubsetUnsupported: #{self.class}##{tag.name} (#{Short.names[tag.name]})"
    end

    def tag_match(v)
      TagNameMatcher.new(v)
    end

    def self.tag_match(v)
      TagNameMatcher.new(v)
    end

    def marshal_dump
      vars={}
      self.class.rec_attributes.each do |var|
        k=var.to_s.delete("@")
        v=self.instance_variable_get("@"+var.to_s)
        vars[k]=v
      end
      vars
    end

    def marshal_load(vars)
      vars.each do |attr, value|
        instance_variable_set("@"+attr, value)
      end
    end

    #    def inspect
    #      vars = instance_variables.collect { |v| v.to_s << "=#{instance_variable_get(v).inspect}"}.join(",\n ")
    #      "#<#{self.class} #{vars}>"
    #    end
  end
end