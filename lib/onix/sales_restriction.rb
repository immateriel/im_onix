require 'onix/sales_outlet'
module ONIX
  class SalesRestriction < SubsetDSL
    element "SalesRestrictionType", :subset, :shortcut => :type
    elements "SalesOutlet", :subset, :cardinality => 0..n
    elements "SalesRestrictionNote", :text, :shortcut => :notes
    element "StartDate", :date, :cardinality => 0..1
    element "EndDate", :date, :cardinality => 0..1

    def note
      self.notes.first
    end
  end
end
