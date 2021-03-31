module ONIX
  class RelatedWork < SubsetDSL
    include EanMethods
    element "WorkRelationCode", :subset, :shortcut => :code, :cardinality => 0..n
    elements "WorkIdentifier", :subset, :shortcut => :identifiers, :cardinality => 0..n

    # full Product if referenced in ONIXMessage
    # @return [Product]
    attr_accessor :product
  end
end