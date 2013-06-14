#!/usr/bin/ruby
require 'im_onix'

filename=ARGV[0]

msg=ONIX::ONIXMessage.new
msg.parse(filename)
msg.products.each do |product|
#  pp product
  puts "---"
  puts " EAN: #{product.ean}"
  puts " Title: #{product.title}"
  if product.subtitle
    puts " Subtitle: #{product.subtitle}"
  end
  puts " Publication date: #{product.publication_date}"
  if product.pages
    puts " Pages: #{product.pages}"
  end
  puts " Description: #{product.raw_description}"

  puts " Publisher: #{product.publisher_name}"
  puts " Imprint: #{product.imprint_name}"
  puts " Distributor: #{product.distributor_name}"

  product.contributors.each do |c|
    puts " Contributors:"
    puts "  Name: #{c.name}"
    puts "  Role: #{c.role.human}"
    if c.biography
      puts "  Biography: #{c.raw_biography}"
    end
  end

  if product.digital?
    puts " ---"
    puts " Digital product"

    if product.bundle?
      puts " Multiple files bundle"
      if product.file_description
        puts " Description: #{product.file_description}"
      end
    else
      puts " Format: #{product.file_format}"
      if product.file_description
        puts " Description: #{product.file_description}"
      end
      puts " Protection: #{product.protection_type}"
      if product.filesize
        puts " Filesize: #{product.filesize} bytes"
      end
    end

    if product.paper_linking
      puts " Paper EAN: #{product.paper_linking.ean}"
    end
  end

  puts " Available: #{product.available?}"
  puts " Prices:"
  product.prices_including_tax.each do |price|
    output=""
    output+="  #{price.amount} #{price.currency} for "

    if price.territory.worldwide?
      output+="WORLD"
    else
      output+=price.territory.countries.join(", ")
    end

    if price.from_date
      output+=" from #{price.from_date}"
    end
    if price.until_date
      output+=" until #{price.until_date}"
    end

    puts  output
  end

end
