require 'onix/sender'
require 'onix/addressee'

module ONIX
  class Header < SubsetDSL
    element "Sender", :subset, :cardinality => 1
    element "Addressee", :subset, :cardinality => 0..n
    element "MessageNumber", :integer, :cardinality => 0..1
    element "MessageRepeat", :integer, :cardinality => 0..1
    element "SentDateTime", :datetime, :cardinality => 1
    element "MessageNote", :text, :cardinality => 0..n
    element "DefaultLanguageOfText", :subset, :klass => "LanguageCode", :cardinality => 0..1
    element "DefaultPriceType", :subset, :klass => "PriceType", :cardinality => 0..1
    element "DefaultCurrencyCode", :text, :cardinality => 0..1
  end
end
