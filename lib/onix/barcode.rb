module ONIX
  class Barcode < SubsetDSL
    element "BarcodeType", :subset, :cardinality => 1
    element "PositionOnProduct", :subset, :cardinality => 0..1
  end
end
