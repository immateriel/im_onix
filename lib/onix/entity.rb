require 'onix/code'
require 'onix/identifier'

module ONIX
  class Entity < Subset
    # entity name
    attr_accessor :name
    # entity role
    attr_accessor :role
    # entity Identifier list
    attr_accessor :identifiers

    include GlnMethods

    def initialize
      @identifiers = []
    end

    def self.role_tag
      "#{self.prefix}Role"
    end

    def self.name_tag
      "#{self.prefix}Name"
    end

    def self.identifier_tag
      "#{self.prefix}Identifier"
    end

    def parse(n)
      n.children.each do |t|
        case t
          when tag_match(self.class.name_tag)
            @name=t.text
          when tag_match(self.class.role_tag)
            if self.class.role_class
              @role=self.class.role_class.parse(t)
            end
          when tag_match(self.class.identifier_tag)
            @identifiers << Identifier.parse_identifier(t,self.class.prefix)
        end
      end
    end

    private
    def self.prefix
    end

    def self.role_class
      nil
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

  class Publisher < Entity
    private
    def self.prefix
      "Publisher"
    end

    def self.role_tag
      "PublishingRole"
    end

    def self.role_class
      PublishingRole
    end
  end

end