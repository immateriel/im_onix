require 'onix/sender'
require 'onix/addressee'

module ONIX
  class Header < SubsetDSL
    element "Sender", :subset
    element "Addresse", :subset
    element "SentDateTime", :datetime
    element "DefaultLanguageOfText", :subset, :klass => "LanguageCode"
    element "DefaultCurrencyCode", :text
  end
end
