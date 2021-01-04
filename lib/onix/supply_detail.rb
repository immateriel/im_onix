require 'onix/supply_contact'
require 'onix/supplier_own_coding'
require 'onix/returns_conditions'
require 'onix/price'

module ONIX
  class SupplyDetail < SubsetDSL
    elements "Supplier", :subset, :cardinality => 1
    elements "SupplyContact", :subset, :cardinality => 0..n
    elements "SupplierOwnCoding", :subset, :cardinality => 0..n
    elements "ReturnsConditions", :subset, :pluralize => false, :cardinality => 0..n
    element "ProductAvailability", :subset, :shortcut => :availability, :cardinality => 1
    elements "SupplyDate", :subset, :cardinality => 0..n
    element "OrderTime", :integer, :cardinality => 0..1
    element "PackQuantity", :integer, :cardinality => 0..1
    element "PalletQuantity", :integer, :cardinality => 0..1
    element "OrderQuantityMinimum", :integer, :cardinality => 0..1
    element "OrderQuantityMultiple", :integer, :cardinality => 0..1
    element "UnpricedItemType", :subset, :cardinality => 0..1
    elements "Price", :subset, :cardinality => 0..n

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
