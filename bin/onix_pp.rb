#!/usr/bin/ruby
require 'im_onix'

filename=ARGV[0]

msg=ONIX::ONIXMessage.new
msg.parse(filename)
msg.products.each do |product|
#  pp product.collateral_detail.supporting_resources
#  pp product.product_supplies
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
    puts " -- Digital product"

    if product.bundle?
      puts " Multiple files bundle"
      if product.file_description
        puts " Description: #{product.raw_file_description}"
      end


      product.parts.each do |part|
        puts "  -- Part"
        puts "  EAN: #{part.ean}"
        puts "  Format: #{part.file_format}"
        puts "  Description: #{part.raw_file_description}"
        if part.product
          puts "  Protection: #{part.product.protection_type}"
          if part.product.filesize
            puts "  Filesize: #{part.product.filesize} bytes"
          end

        end

      end

    else
      puts " Single file"
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
#  pp product.supplies

  current_price=product.current_price_amount_for('EUR')
  if current_price
    puts " Current price: #{current_price/100.0} EUR"
  end
  puts " Prices:"
  product.supplies_including_tax.each do |supply|
    output=""
    output+="  #{supply[:price]} #{supply[:currency]} for "

    if ONIX::Territory.worldwide?(supply[:territory])
      output+="WORLD"
    else
      output+=supply[:territory].join(", ")
    end

    if supply[:from_date]
      output+=" from #{supply[:from_date]}"
    end
    if supply[:until_date]
      output+=" until #{supply[:until_date]}"
    end

    puts  output
  end

end
