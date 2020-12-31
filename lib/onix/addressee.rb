require 'onix/identifier'

module ONIX
  class Addressee < SubsetDSL
    include GlnMethods

    elements "AddresseeIdentifier", :subset, :shortcut => :identifiers, :cardinality => 0..n
    element "AddresseeName", :text, :shortcut => :name, :cardinality => 0..1
  end
end