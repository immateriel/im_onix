#!/usr/bin/env ruby
require 'im_onix'

filename=ARGV[0]

if filename
  bench=Benchmark.measure do
    msg=ONIX::ONIXMessage.new
    msg.parse(filename)
  end
  puts bench
else
  puts "ImOnix parse benchmark"
  puts "Usage: onix_bench.rb file.xml"
end
