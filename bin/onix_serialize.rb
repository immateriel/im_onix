#!/usr/bin/env ruby
require 'im_onix'
require 'onix/serializer'
filename = ARGV[0]
format = ARGV[1] || "dump"
version = ARGV[2]

if filename
  msg = ONIX::ONIXMessage.new
  msg.parse(filename, nil, version)
  case format
  when "dump"
    ONIX::Serializer::Dump.serialize(STDOUT, msg)
  when "xml"
    builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
      ONIX::Serializer::Default.serialize(xml, msg)
    end
    puts builder.to_xml
  end
else
  puts "ImOnix serializer"
  puts "Usage: onix_serialize.rb file.xml [dump|xml] [3.0|2.1]"
end
