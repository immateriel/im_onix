#!/usr/bin/env ruby
require 'benchmark'
require 'objspace'
require 'im_onix'

filename = ARGV[0]

if filename
  GC.start
  old_memsize = ObjectSpace.count_objects_size[:TOTAL]
  msg = ONIX::ONIXMessage.new
  bench = Benchmark.measure do
    msg.parse(filename)
  end
  GC.start
  new_memsize = ObjectSpace.count_objects_size[:TOTAL]
  puts "Parsed #{msg.products.length} products in #{bench.real.round(3)} seconds resulting in use of #{new_memsize - old_memsize} bytes of memory"
else
  puts "ImOnix parse benchmark"
  puts "Usage: onix_bench.rb file.xml"
end
