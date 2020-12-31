require 'onix/code'
require 'onix/identifier'
require 'onix/website'

module ONIX
  module EntityHelper
  end

  class Entity < SubsetDSL
    include GlnMethods
    include EntityHelper

    def self.role_tag
      "#{self.prefix}Role"
    end

    def self.name_tag
      "#{self.prefix}Name"
    end

    def self.identifier_tag
      "#{self.prefix}Identifier"
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

      self.element self.role_tag, :subset, :klass => self.role_class.to_s, :shortcut => :role, :cardinality => 1
      self.elements self.identifier_tag, :subset, :klass => self.identifier_class.to_s, :shortcut => :identifiers, :cardinality => 0..n
      self.element self.name_tag, :text, :shortcut => :name, :cardinality => 0..1
    end
  end

  class Agent < Entity
    entity_setup "Agent", AgentIdentifier, AgentRole
  end

  class Imprint < Entity
    entity_setup "Imprint", ImprintIdentifier
  end

  class Supplier < Entity
    entity_setup "Supplier", SupplierIdentifier, SupplierRole
    elements "Website", :subset
  end

  class Publisher < Entity
    # @note role tag is not PublisherRole but PublishingRole
    def self.role_tag
      "PublishingRole"
    end

    entity_setup "Publisher", PublisherIdentifier, PublishingRole
    elements "Website", :subset
  end
end