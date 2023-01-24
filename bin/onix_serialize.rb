#!/usr/bin/ruby
require 'im_onix'
require 'onix/serializer'
filename=ARGV[0]
version=ARGV[1]

if filename
  msg=ONIX::ONIXMessage.new
  msg.parse(filename, nil, version)
  if true
    msg.products.each do |product|
      ONIX::Serializer::Dump::Subset.serialize(STDOUT, "Product", product)
    end
  end

  if false
    builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
      xml.ONIXMessage {
        msg.products.each do |product|
          ONIX::Serializer::Default::Subset.serialize(xml, "Product", product)
        end
      }
    end
    puts builder.to_xml
  end

end