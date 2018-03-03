#!/usr/bin/ruby
require 'im_onix'

filename=ARGV[0]
version=ARGV[1]

if filename
  msg=ONIX::ONIXMessage.new
  msg.parse(filename,nil,version)
  builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
    xml.ONIXMessage {
      msg.products.each do |product|
        xml.Product {
          product.serialize(xml)
        }
      end
    }
  end
  puts builder.to_xml

end