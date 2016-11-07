#!/usr/bin/ruby
require 'im_onix'

filename=ARGV[0]

if filename
  msg=ONIX::ONIXMessage.new
  msg.parse(filename)

#m=File.open("test.dump","wb")
#m.write Marshal.dump(msg)
#m.close
  puts "Release: #{msg.release}"

  if msg.sender
    puts "Sender: #{msg.sender.name}"
    if msg.sender.gln
      puts "Sender's GLN: #{msg.sender.gln}"
    end
  end
  if msg.sent_date_time
    puts "Sent date: #{msg.sent_date_time}"
  end

  msg.products.each do |product|
#  pp product
    puts "---"
    puts " EAN: #{product.ean}"
    puts " Title: #{product.title}"
    puts " Language: #{product.language_name_of_text} (#{product.language_code_of_text})"
    if product.subtitle
      puts " Subtitle: #{product.subtitle}"
    end
    if product.publication_date
      puts " Publication date: #{product.publication_date}"
    end
    if product.embargo_date
      puts " Embargo date: #{product.embargo_date}"
    end
    if product.preorder_embargo_date
      puts " Preorder embargo date: #{product.preorder_embargo_date}"
    end
    if product.public_announcement_date
      puts " Public announcement date: #{product.public_announcement_date}"
    end
    if product.pages
      puts " Pages: #{product.pages}"
    end
    if product.publisher_collection_title
      puts " Collection: #{product.publisher_collection_title}"
    end

    product.bisac_categories_codes.each do |bcc|
      puts " BISAC: #{bcc}"
    end

    product.clil_categories_codes.each do |bcc|
      puts " CLIL: #{bcc}"
    end

    puts " Description: #{product.raw_description}"

    if product.frontcover_url
      puts " Frontcover: #{product.frontcover_url} (#{product.frontcover_last_updated})"
    end

    if product.epub_sample_url
      puts " Sample: #{product.epub_sample_url}"
    end

    if product.keywords.length > 0
      puts " Keywords: #{product.keywords.join(', ')}"
    end

    if product.publisher_name
      puts " Publisher: #{product.publisher_name}"
    end

#  puts " Publisher: #{product.publisher_name}"
    if product.imprint_name
      puts " Imprint: #{product.imprint_name}"
    end

    if product.distributor_name
      puts " Distributor: #{product.distributor_name}"
    end

    if product.onix_outlets_values.length > 0
      puts " Outlets: #{product.onix_outlets_values}"
    end

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
          puts " Description: #{product.raw_file_description}"
        end
        if product.protection_type
          puts " Protection: #{product.protection_type}"
        end
        if product.filesize
          puts " Filesize: #{product.filesize} bytes"
        end
      end

      if product.print_product
        puts " Paper EAN: #{product.print_product.ean}"
      end
    end

#  pp product.supplies

    current_price=product.current_price_amount_for('EUR', 'FR')
    if current_price
      puts " Current EUR price for FR: #{current_price/100.0} EUR"
    end

    if product.sold_separately?
      puts " Available: #{product.available?}"
      puts " Supplies:"

      product.supplies_with_default_tax.each do |supply|
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
          output+=" (#{supply[:availability_date].to_date})" if supply[:availability_date].class==Time

        end

        puts output

        puts "  Prices:"

        supply[:prices].each do |price|
          output="   "

          output+="#{price[:amount].to_f/100.0} #{supply[:currency]}"

          if supply[:including_tax]
            output+=" tax included"
          else
            output+=" tax excluded"
          end

          if price[:from_date]
            output+=" from #{price[:from_date]}"
            output+=" (#{price[:from_date].to_date})" if price[:from_date].class==Time
          end
          if price[:until_date]
            output+=" until #{price[:until_date]}"
            output+=" (#{price[:until_date].to_date})" if price[:until_date].class==Time
          end
          puts output
        end
      end
    else
      puts " Not sold separately"
    end
  end
  puts "---"
  puts "Number of products: #{msg.products.count}"

else
  puts "ONIX 3.0 pretty printer"
  puts "Usage: onix_pp.rb onix.xml"
end
