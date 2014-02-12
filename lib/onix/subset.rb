module ONIX
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

#    def inspect
#      vars = instance_variables.collect { |v| v.to_s << "=#{instance_variable_get(v).inspect}"}.join(",\n ")
#      "#<#{self.class} #{vars}>"
#    end
  end
end