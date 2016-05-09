require 'onix/code'
module ONIX
  class Website < Subset
    attr_accessor :role, :link, :description

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("WebsiteRole")
            @role=WebsiteRole.parse(t)
          when tag_match("WebsiteLink")
            @link=t.text
          when tag_match("WebsiteDescription")
            @description=t.text.strip
        end
      end
    end
  end
end
