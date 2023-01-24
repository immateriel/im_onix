require 'onix/sender'
require 'onix/addressee'

module ONIX
  class Header < SubsetDSL
    element "Sender", :subset, :cardinality => 1
    element "Addressee", :subset, :cardinality => 0..n
    element "MessageNumber", :integer, :cardinality => 0..1
    element "MessageRepeat", :integer, :cardinality => 0..1
    element "SentDateTime", :datestamp, :cardinality => 1,
            :serialize_lambda => lambda {|v| v.is_a?(Time) ? v.strftime("%Y%m%dT%H%M%S%z") : v}
    element "MessageNote", :text, :cardinality => 0..n
    element "DefaultLanguageOfText", :subset, :klass => "LanguageCode", :cardinality => 0..1
    element "DefaultPriceType", :subset, :klass => "PriceType", :cardinality => 0..1
    element "DefaultCurrencyCode", :text, :cardinality => 0..1
  end
end
