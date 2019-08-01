#!/usr/bin/env ruby
require 'im_onix'
require 'nokogiri'

filename=ARGV[0]

if filename
msg=ONIX::ONIXMessage.new
msg.parse(filename)

builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
  xml.doc.create_internal_subset(
      'ONIXMessage',
      nil,
      "http://www.editeur.org/onix/2.1/reference/onix-international.dtd"
  )
  xml.ONIXMessage {
    xml.Header {
      if msg.sender and msg.sender.name
        xml.FromCompany(msg.sender.name)
      else
        xml.FromCompany("Any")
      end
      xml.ToCompany("Any")
    }

msg.products.each do |product|
  xml.Product {
    xml.RecordReference(product.ean)
    xml.NotificationType("03")

    xml.ProductIdentifier {
      xml.ProductIDType("03")
      xml.IDValue(product.ean)

    }

    xml.ProductForm("DG")

    case product.file_format
      when "Pdf"
        xml.EpubType("002")
      when "Epub"
        xml.EpubType("029")
      else
        xml.EpubType("000")
    end

#    if @book.book_collection
#      xml.Series {
#        xml.TitleOfSeries(@book.book_collection.title)
#      }
#    end

    xml.Title {
      xml.TitleType("01")
      xml.TitleText(product.title)
      if product.subtitle
        xml.Subtitle(product.subtitle)
      end
    }

    i=1
    product.contributors.each do |a|
        xml.Contributor {
          xml.SequenceNumber(i)
          xml.ContributorRole(a.role.code)
          xml.PersonName(a.name)
          if a.biography
            xml.BiographicalNote(a.biography)
          end
        }
        i=i+1
    end

#    xml.EditionNumber(@book.edition)

    if product.language_of_text
    xml.Language {
      xml.LanguageRole("01")
      xml.LanguageCode(product.language_of_text)
    }
    end

    if product.pages
      xml.NumberOfPages(product.pages)
    end

    product.bisac_categories.each do |ct|
      xml.BASICMainSubject(ct.code)
    end

    xml.OtherText {
      xml.TextTypeCode("01")
      xml.Text(product.description)
    }

    if product.imprint_name
    xml.Imprint {
      xml.ImprintName(product.imprint_name)
    }
    end

    xml.Publisher {
      xml.PublishingRole("01")
      xml.PublisherName(product.publisher_name)
    }


    if product.available?
      xml.PublishingStatus("04")
    else
      xml.PublishingStatus("08")
    end

    xml.PublicationDate(product.publication_date.strftime("%Y%m%d"))

    xml.SalesRights {
      xml.SalesRightsType("01")
      xml.RightsCountry(product.countries_rights.join(" "))
    }

    if product.print_product
      xml.RelatedProduct {
        xml.RelationCode("13")

        xml.ProductIdentifier {
          xml.ProductIDType("03")
          xml.IDValue(product.print_product.ean)
        }
      }

    end

    product.supplies.each do |supply|
    xml.SupplyDetail {
      if product.distributor_name
        xml.SupplierName(product.distributor_name)
      else
        xml.SupplierName("Unknown")
      end


      if supply[:available]
        xml.ProductAvailability("20")
      else
        xml.ProductAvailability("40")
      end

      if supply[:availability_date]
        xml.OnSaleDate(supply[:availability_date].strftime("%Y%m%d"))
      else
        xml.OnSaleDate(product.publication_date.strftime("%Y%m%d"))
      end

        supply[:prices].each do |price|
          xml.Price {
            if supply[:including_tax]
              xml.PriceTypeCode("04")
            else
              xml.PriceTypeCode("03")
            end
            xml.PriceAmount(price[:amount]/100.0)
            xml.CurrencyCode(supply[:currency])
            supply[:territory].each do |t|
              xml.CountryCode(t)
            end

            if price[:from_date] then
              xml.PriceEffectiveFrom(price[:from_date].strftime("%Y%m%d"))
            end
            if price[:until_date]
              xml.PriceEffectiveUntil(price[:until_date].strftime("%Y%m%d"))
            end

          }
        end

    }
    end

  }
end
  }

end

puts builder.to_xml
else
  puts "ONIX 3.0 to ONIX 2.1 converter"
  puts "Usage: onix3_to_onix2.rb onix.xml"
end
