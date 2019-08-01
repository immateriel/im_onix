#!/usr/bin/env ruby
require 'im_onix'

filename=ARGV[0]
cnt=ARGV[1] || 1000
cnt=cnt.to_i

class OnixSplitter

  def initialize(filename, output_name)
    @filename=filename
    @output_name=output_name
  end

  def write_part(file_count, part)
    out_filename=@output_name+"."+file_count.to_s+".xml"
    puts "Write file #{out_filename}"
    fw=File.open(out_filename, 'w')
    fw.write("<ONIXMessage release=\"3.0\">\n")
    part.each do |p|
      fw.write p
    end
    fw.write("</ONIXMessage>\n")
    fw.close
  end

  def count
    current_part_count=0
    ONIX::Helper.each_xml_product(@filename) do |product_str|
      current_part_count+=1
    end
    current_part_count
  end

  def split(max_parts)
    file_count=0
    current_part=[]
    current_part_count=0
    ONIX::Helper.each_xml_product(@filename) do |product_str|
      tmp_msg=ONIX::ONIXMessage.new
      tmp_msg.parse(product_str)

      current_part[current_part_count] ||=""
      current_part[current_part_count] += product_str + "\n"

      if tmp_msg.products.first.sold_separately?
        current_part_count+=1
      end

      if current_part_count > max_parts-1
        write_part(file_count, current_part)
        current_part=[]
        current_part_count=0
        file_count+=1
      end
    end

    if current_part_count > 0
      write_part(file_count, current_part)
      current_part=[]
      current_part_count=0
    end

    true
  end

end

splitter=OnixSplitter.new(filename, "out/splitted")
splitter.split(cnt)
puts splitter.count

