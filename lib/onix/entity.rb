require 'onix/code'
require 'onix/identifier'

module ONIX
  class Entity
    # entity name
    attr_accessor :name
    # entity role
    attr_accessor :role
    # entity Identifier list
    attr_accessor :identifiers

    include GlnMethods

    # create Entity array from Nokogiri:XML::Node
    def self.parse_entities(node,list_tag)
      entities=[]
      node.search(list_tag).each do |n|
        entities << self.from_hash({:name => n.at("./#{self.prefix}Name").text,
                          :role => if self.role_class then self.role_class.from_code(n.at("./#{self.prefix}Role").text) else nil end,
                          :identifiers => Identifier.parse_identifiers(n, prefix)})
      end
      entities

    end

    private
    def self.prefix
    end
    def self.role_class
      nil
    end
    def self.from_hash(h)
      o=self.new
      o.name=h[:name]
      o.role=h[:role]
      o.identifiers=h[:identifiers]
      o
    end
  end

  class Agent < Entity
    private
    def self.prefix
      "Agent"
    end

    def self.role_class
      AgentRole
    end
  end

  class Publisher < Entity
    private
    def self.prefix
      "Publisher"
    end

    def self.role_class
      nil
    end
  end

  class Imprint < Entity
    private
    def self.prefix
      "Imprint"
    end

    def self.role_class
      nil
    end
  end

  class Supplier < Entity
    private
    def self.prefix
      "Supplier"
    end

    def self.role_class
      SupplierRole
    end
  end
end