require 'onix/sales_outlet'
module ONIX
  class SalesRestriction < SubsetDSL
    element "SalesRestrictionType", :subset, :shortcut => :type
    elements "SalesOutlet", :subset
    element "SalesRestrictionNote", :text, :shortcut => :note

    attr_accessor :start_date, :end_date

    def parse(n)
      super
      n.elements.each do |t|
        case t
        when tag_match("StartDate")
          fmt = t["dateformat"] || "00"
          @start_date = ONIX::Helper.to_date(fmt, t.text)
        when tag_match("EndDate")
          fmt = t["dateformat"] || "00"
          @end_date = ONIX::Helper.to_date(fmt, t.text)
        end
      end
    end
  end
end
