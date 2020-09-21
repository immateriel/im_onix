require 'onix/identifier'

module ONIX
  class Sender < SubsetDSL
    include GlnMethods

    elements "SenderIdentifier", :subset, :shortcut => :identifiers
    element "SenderName", :text, :shortcut => :name
    element "ContactName", :text
    element "EmailAddress", :text
  end
end
