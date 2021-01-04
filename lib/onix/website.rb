require 'onix/code'
module ONIX
  class Website < SubsetDSL
    element "WebsiteRole", :subset, :shortcut => :role, :cardinality => 0..1
    element "WebsiteDescription", :text, :shortcut => :description, :cardinality => 0..n
    element "WebsiteLink", :text, :shortcut => :link, :cardinality => 1..n
  end
end
