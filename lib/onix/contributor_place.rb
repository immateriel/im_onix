module ONIX
  class ContributorPlace < SubsetDSL
    element "ContributorPlaceRelator", :subset, :shortcut => :relator, :cardinality => 1
    element "CountryCode", :subset, :cardinality => 0..1
    element "RegionCode", :subset, :cardinality => 0..1
    elements "LocationName", :text, :cardinality => 0..n

    def country_code
      @country_code.code
    end
  end
end