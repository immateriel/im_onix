require 'onix/code'
require 'onix/identifier'

module ONIX
  class Entity
    attr_accessor :name, :role, :identifiers

    include GlnMethods

    def self.from_hash(h)
      o=self.new
      o.name=h[:name]
      o.role=h[:role]
      o.identifiers=h[:identifiers]
      o
    end

    def self.parse_entities(node,list_tag)
      entities=[]
      node.search(list_tag).each do |n|
        entities << self.from_hash({:name => n.at("./#{self.prefix}Name").text,
                          :role => if self.role_class then self.role_class.from_code(n.at("./#{self.prefix}Role").text) else nil end,
                          :identifiers => Identifier.parse_identifiers(n, prefix)})
      end
      entities

    end

  end

  class Agent < Entity
    def self.prefix
      "Agent"
    end

    def self.role_class
      AgentRole
    end
  end

  class Publisher < Entity
    def self.prefix
      "Publisher"
    end

    def self.role_class
      nil
    end
  end

  class Imprint < Entity
    def self.prefix
      "Imprint"
    end

    def self.role_class
      nil
    end
  end

  class Supplier < Entity
    def self.prefix
      "Supplier"
    end

    def self.role_class
      SupplierRole
    end
  end
end