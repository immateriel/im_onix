require 'onix/sender'
require 'onix/addressee'

module ONIX
  class Header < SubsetDSL
    attr_accessor :sent_date_time

    element "Sender", :subset
    element "Addresse", :subset
    element "DefaultLanguageOfText", :subset, { :klass => "LanguageCode" }
    element "DefaultCurrencyCode", :text

    def parse(n)
      super
      n.elements.each do |t|
        case t
        when tag_match("SentDateTime")
          tm = t.text
          @sent_date_time = Time.strptime(tm, "%Y%m%dT%H%M%S") rescue Time.strptime(tm, "%Y%m%dT%H%M") rescue Time.strptime(tm, "%Y%m%d") rescue nil
        end
      end
    end
  end
end
