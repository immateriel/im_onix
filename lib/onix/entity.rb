require 'onix/code'
require 'onix/identifier'
require 'onix/website'

module ONIX
  module EntityHelper
  end

  class Entity < SubsetDSL
    # entity name
    attr_accessor :name
    # entity role
    attr_accessor :role
    # entity Identifier list
    attr_accessor :identifiers

    include GlnMethods
    include EntityHelper

    def initialize
      super
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
      super
      n.children.each do |t|
        case t
        when tag_match(self.class.name_tag)
          @name = t.text
        when tag_match(self.class.role_tag)
          if self.class.role_class
            @role = self.class.role_class.parse(t)
          end
        when tag_match(self.class.identifier_tag)
          if self.class.identifier_class
            @identifiers << self.class.identifier_class.parse(t)
          end
        end
      end
    end

    def self.prefix
    end

    def self.identifier_class
      nil
    end

    def self.role_class
      nil
    end

    def self.entity_setup prefix, identifier, role = nil
      define_singleton_method :prefix do
        return prefix
      end
      define_singleton_method :identifier_class do
        return identifier
      end
      define_singleton_method :role_class do
        return role
      end
    end
  end

  class Agent < Entity
    entity_setup "Agent", AgentIdentifier, AgentRole
  end

  class Imprint < Entity
    entity_setup "Imprint", ImprintIdentifier
  end

  class Supplier < Entity
    elements "Website", :subset
    entity_setup "Supplier", SupplierIdentifier, SupplierRole
  end

  class Publisher < Entity
    elements "Website", :subset
    entity_setup "Publisher", PublisherIdentifier, PublishingRole

    # @note role tag is not PublisherRole but PublishingRole
    def self.role_tag
      "PublishingRole"
    end
  end
end