module ONIX
  class CollectionSequence < SubsetDSL
    element "CollectionSequenceType", :subset, :shortcut => :type
    element "CollectionSequenceTypeName", :string, :shortcut => :type_name
    element "CollectionSequenceNumber", :string, :shortcut => :number
  end
end
