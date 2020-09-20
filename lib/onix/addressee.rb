require 'onix/identifier'

module ONIX
  class Addressee < SubsetDSL
    include GlnMethods

    elements "AddresseeIdentifier", :subset, :shortcut => :identifiers
    element "AddresseeName", :text, :shortcut => :name
  end
end