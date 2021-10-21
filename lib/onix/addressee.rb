require 'onix/identifier'

module ONIX
  class Addressee < SubsetDSL
    include IdentifiersMethods::Gln

    elements "AddresseeIdentifier", :subset, :shortcut => :identifiers, :cardinality => 0..n
    element "AddresseeName", :text, :shortcut => :name, :cardinality => 0..1
    element "ContactName", :text, :cardinality => 0..1
    element "EmailAddress", :text, :cardinality => 0..1
  end
end