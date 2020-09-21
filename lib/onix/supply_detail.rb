require 'onix/price'

module ONIX
  class SupplyDetail < SubsetDSL
    elements "Supplier", :subset
    element "ProductAvailability", :subset, :shortcut => :availability
    elements "SupplyDate", :subset
    elements "Price", :subset
    element "UnpricedItemType", :subset

    # @!group Shortcuts
    def distributors
      @suppliers.select { |s| s.role.human =~ /Distributor/ }.uniq
    end

    # @!endgroup

    # @!group High level
    # is supply available ?
    # @return [Boolean]
    def available?
      ["Available", "NotYetAvailable", "InStock", "ToOrder", "Pod"].include?(@product_availability.human)
    end

    # does supply can be sold separately ?
    # @return [Boolean]
    def sold_separately?
      @product_availability.human != "NotSoldSeparately"
    end

    # supply availability date
    # @return [Date]
    def availability_date
      av = @supply_dates.availability.first
      if av
        av.date
      end
    end

    # @!endgroup
  end
end
