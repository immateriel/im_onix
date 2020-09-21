module ONIX
  class RelatedWork < SubsetDSL
    include EanMethods
    element "WorkRelationCode", :subset, :shortcut => :code
    elements "WorkIdentifier", :subset, :shortcut => :identifiers

    # full Product if referenced in ONIXMessage
    attr_accessor :product
  end
end