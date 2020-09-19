require 'onix/code'
module ONIX
  class Website < SubsetDSL
    element "WebsiteRole", :subset, :shortcut => :role
    element "WebsiteLink", :text, :shortcut => :link
    element "WebsiteDescription", :text, :shortcut => :description
  end
end
