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
  puts " Language: #{product.language_of_text}"
  if product.subtitle
    puts " Subtitle: #{product.subtitle}"
  end
  if product.publication_date
    puts " Publication date: #{product.publication_date}"
  end
  if product.pages
    puts " Pages: #{product.pages}"
  end
  if product.publisher_collection_title
    puts " Collection: #{product.publisher_collection_title}"
  end
  puts " Description: #{product.raw_description}"

  puts " Frontcover: #{product.frontcover_url}"

  if product.keywords.length > 0
    puts " Keywords: #{product.keywords.join(', ')}"
  end

  if product.publishers.length > 0
  product.publishers.each do |publisher|
    puts " Publisher: #{publisher.name}"
  end
  end

#  puts " Publisher: #{product.publisher_name}"
  if product.imprint_name
    puts " Imprint: #{product.imprint_name}"
  end
  puts " Distributor: #{product.distributor_name}"

  product.contributors.each do |c|
    puts " Contributor:"
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
        if part.ean
          puts "  EAN: #{part.ean}"
        end
        puts "  Format: #{part.file_format}"
        if part.file_description
          puts "  Description: #{part.raw_file_description}"
        end
        if part.protection_type
          puts "  Protection: #{part.protection_type}"
        end
        if part.filesize
          puts "  Filesize: #{part.filesize} bytes"
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
  puts " Supplies:"
  product.supplies_including_tax.each do |supply|
#    if supply[:availability_date]
#      puts " Availability date : #{supply[:availability_date]}"
#    end

    output="  "

    if supply[:available]
      output+="Available in "
    else
      output+="Not available in "
    end

    if ONIX::Territory.worldwide?(supply[:territory])
      output+="WORLD"
    else
      output+=supply[:territory].join(", ")
    end

    if supply[:availability_date]
      output+=" starting #{supply[:availability_date]}"
    end

    puts output

    puts "  Prices:"


    supply[:prices].each do |price|
      output="   "

      output+="#{price[:amount].to_f/100.0} #{supply[:currency]}"

    if price[:from_date]
      output+=" from #{price[:from_date]}"
    end
    if price[:until_date]
      output+=" until #{price[:until_date]}"
    end
      puts  output

    end

  end

end
