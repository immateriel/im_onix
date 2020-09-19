module ONIX
  class SalesOutlet < SubsetDSL
    element "SalesOutletIdentifier", :subset, :shortcut => :identifier
    element "SalesOutletName", :text, :shortcut => :name
  end
end
