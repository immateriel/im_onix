require 'onix/sales_outlet'
module ONIX
  class SalesRestriction < SubsetDSL
    element "SalesRestrictionType", :subset, :shortcut => :type
    elements "SalesOutlet", :subset
    elements "SalesRestrictionNote", :text, :shortcut => :notes
    element "StartDate", :date, :cardinality => 0..1
    element "EndDate", :date, :cardinality => 0..1

    def note
      self.notes.first
    end
  end
end
