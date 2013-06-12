#!/usr/bin/ruby
require 'im_onix'

filename=ARGV[0]

msg=ONIX::ONIXMessage.new
msg.parse(filename)
msg.products.each do |product|
  pp product
  puts "---"
  if product.paper_linking
    puts " Paper EAN: #{product.paper_linking.ean}"
  end
  puts " EAN: #{product.ean}"
  puts " Title: #{product.title}"
  puts " Subtitle: #{product.subtitle}"
  puts " Publication date: #{product.publication_date}"
  puts " Description: #{product.raw_description}"

  puts " Publisher: #{product.publisher_name}"
  puts " Imprint: #{product.imprint_name}"
  puts " Distributor: #{product.distributor_name}"

  product.contributors.each do |c|
    puts " Contributors:"
    puts "  Name: #{c.name}"
    puts "  Role: #{c.role.human}"
    puts "  Biography: #{c.raw_biography}"
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
