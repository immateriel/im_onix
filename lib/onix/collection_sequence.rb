module ONIX
  class CollectionSequence < SubsetDSL
    element "CollectionSequenceType", :subset, :shortcut => :type, :cardinality => 1
    element "CollectionSequenceTypeName", :string, :shortcut => :type_name, :cardinality => 0..1
    element "CollectionSequenceNumber", :string, :shortcut => :number, :cardinality => 1
  end
end
