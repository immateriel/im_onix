module ONIX
  class Prize < SubsetDSL
    elements "PrizeName", :text, :cardinality => 1..n
    element "PrizeYear", :text, :cardinality => 0..1
    element "PrizeCountry", :subset, :klass => "CountryCode", :cardinality => 0..1
    element "PrizeRegion", :subset, :klass => "RegionCode", :cardinality => 0..1
    element "PrizeCode", :subset, :cardinality => 0..1
    elements "PrizeStatement", :text, :cardinality => 0..n
    elements "PrizeJury", :text, :cardinality => 0..n
  end
end