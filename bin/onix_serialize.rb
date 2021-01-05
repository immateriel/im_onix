#!/usr/bin/env ruby
require 'im_onix'
require 'onix/serializer'
filename = ARGV[0]
version = ARGV[1]

if filename
  msg = ONIX::ONIXMessage.new
  msg.parse(filename, nil, version)
  ONIX::Serializer::Dump.serialize(STDOUT, msg)

  if false
    builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
      #      ONIX::Serializer::Default::Root.serialize(xml, "ONIXMessage", msg)
      ONIX::Serializer::Default.serialize(xml, msg)
    end
    puts builder.to_xml
  end
end
