require 'onix/identifier'

module ONIX
  class Sender < SubsetDSL
    include IdentifiersMethods::Gln

    elements "SenderIdentifier", :subset, :shortcut => :identifiers, :cardinality => 0..n
    element "SenderName", :text, :shortcut => :name, :cardinality => 0..1
    element "ContactName", :text, :cardinality => 0..1
    element "EmailAddress", :text, :cardinality => 0..1
  end
end
