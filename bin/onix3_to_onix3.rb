require 'im_onix'
require 'nokogiri'

filename=ARGV[0]

if filename
msg=ONIX::ONIXMessage.new
msg.parse(filename)

builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
  xml.ONIXMessage(:release=>"3.0", :xmlns=>"http://ns.editeur.org/onix/3.0/reference") {
    xml.Header {
      if msg.sender
        xml.Sender {
          xml.SenderName(msg.sender.name)
        }
      end
      if msg.sent_date_time
        xml.SentDateTime(msg.sent_date_time.strftime("%Y%m%dT%H%M"))
      end
    }
    msg.products.each do |product|
      xml.Product {
      xml.RecordReference(product.ean)
      if product.delete?
        xml.NotificationType("05")
      else
        xml.NotificationType("03")
      end
      xml.ProductIdentifier {
        xml.ProductIDType("03")
        xml.IDValue(product.ean)
      }

      xml.DescriptiveDetail {
        if product.bundle?
          xml.ProductComposition("10")
        else
          xml.ProductComposition("00")
        end

        if product.digital?
          xml.ProductForm("EA")
        else
          xml.ProductForm("BA")
        end

        if product.bundle?
          product.parts.each do |part|
            xml.ProductPart {
              xml.ProductIdentifier {
                xml.ProductIDType("03")
                xml.IDValue(part.ean)
              }

              if part.file_format
              xml.ProductForm("EA")
              case part.file_format
                when "Epub"
                  xml.ProductFormDetail("E101")
                when "Pdf"
                  xml.ProductFormDetail("E107")
                when "Mobipocket"
                  xml.ProductFormDetail("E127")
                else
                  xml.ProductFormDetail("E100")
                  xml.ProductFormDescription(part.file_description)

              end

              end
              xml.NumberOfCopies("1")

            }
          end
        else
          if product.digital?
          case product.file_format
            when "Epub"
              xml.ProductFormDetail("E101")
            when "Pdf"
              xml.ProductFormDetail("E107")
            when "Mobipocket"
              xml.ProductFormDetail("E127")
            else
              xml.ProductFormDetail("E100")
              xml.ProductFormDescription(product.file_description)
          end


          case product.protection_type
            when "None"
              xml.EpubTechnicalProtection("00")
            when "Drm"
              xml.EpubTechnicalProtection("01")
            when "DigitalWatermarking"
              xml.EpubTechnicalProtection("02")
            when "AdobeDrm"
              xml.EpubTechnicalProtection("03")
          end
          end
        end



        if product.publisher_collection_title
          xml.Collection {
            xml.CollectionType("10")
            xml.TitleDetail {
              xml.TitleType("01")
              xml.TitleElement {
                xml.TitleElementLevel("02")
                xml.TitleText(product.publisher_collection_title)
              }
            }
          }
        end

        xml.TitleDetail {
          xml.TitleType("01")
          xml.TitleElement {
            xml.TitleElementLevel("01")
            xml.TitleText(product.title)
            if product.subtitle
              xml.TitleText(product.subtitle)
            end
          }
        }

        product.contributors.each do |c|
          xml.Contributor {
            xml.SequenceNumber(c.sequence_number)
            xml.ContributorRole(c.role.code)
            xml.PersonName(c.name)
          }
        end

        if product.edition_number
          xml.EditionNumber(product.edition_number)
        end

        if product.language_of_text
          xml.Language {
            xml.LanguageRole("01")
            xml.LanguageCode(product.language_of_text.code)
          }
        end

        product.bisac_categories_codes.each do |s|
          xml.Subject {
            xml.SubjectSchemeIdentifier("10")
            xml.SubjectCode(s)
          }
        end
        product.clil_categories_codes.each do |s|
          xml.Subject {
            xml.SubjectSchemeIdentifier("29")
            xml.SubjectCode(s)
          }
        end

        if product.keywords.length > 0
          xml.Subject {
            xml.SubjectSchemeIdentifier("20")
            xml.SubjectHeadingText(product.keywords.join(", "))
          }
        end

      }
      xml.CollateralDetail {
        xml.TextContent {
          xml.TextType("03")
          xml.ContentAudience("00")
          xml.Text(product.description)
        }

        # front cover
        if product.frontcover_url
        xml.SupportingResource {
          xml.ResourceContentType("01")
          xml.ContentAudience("00")
          xml.ResourceMode("03")
          xml.ResourceVersion {
            xml.ResourceForm("02")
            xml.ResourceLink(product.frontcover_url)
          }
        }
        end

        # sample
        if product.epub_sample_url
        xml.SupportingResource {
          xml.ResourceContentType("15")
          xml.ContentAudience("00")
          xml.ResourceMode("04")
          xml.ResourceVersion {
            xml.ResourceForm("02")
              xml.ResourceVersionFeature {
                xml.ResourceVersionFeatureType("01")
                xml.FeatureValue("E101")
              }
            xml.ResourceLink(product.epub_sample_url)
          }
        }
        end

      }
      xml.PublishingDetail {
        if product.imprint
        xml.Imprint {
          if product.imprint_gln
          xml.ImprintIdentifier {
            xml.ImprintIDType("06")
            xml.IDValue(product.imprint_gln)
          }
          end
          xml.ImprintName(product.imprint_name)
        }
        end
        if product.publisher_name
        xml.Publisher {
          xml.PublishingRole("01")
          if product.publisher_gln
          xml.PublisherIdentifier {
            xml.PublisherIDType("06")
            xml.IDValue(product.publisher_gln)
          }
          end
          xml.PublisherName(product.publisher_name)
        }
        end

        if product.publication_date
          xml.PublishingDate {
            xml.PublishingDateRole("01")
            xml.DateFormat("00")
            xml.Date(product.publication_date.strftime("%Y%m%d"))
          }
        end
      }

      xml.RelatedMaterial {
        if product.print_product
          xml.RelatedProduct {
            xml.ProductRelationCode("13")
            xml.ProductIdentifier {
              xml.ProductIDType("03")
              xml.IDValue(product.print_product.ean)
            }
          }
        end

        unless product.sold_separately?
          if product.part_of_product
            xml.RelatedProduct {
              xml.ProductRelationCode("02")
              xml.ProductIdentifier {
                xml.ProductIDType("03")
                xml.IDValue(product.part_of_product.ean)
              }
            }
          end
        end

          }

      if product.sold_separately?
      product.supplies.each do |supply|
        xml.ProductSupply {
          xml.Market {
            xml.Territory {
              if ONIX::Territory.worldwide?(supply[:territory])
                xml.RegionsIncluded("WORLD")
              else
                xml.CountriesIncluded(supply[:territory].join(" "))
              end
            }
          }
          xml.MarketPublishingDetail {
            if supply[:available]
              xml.MarketPublishingStatus("04")
            else
              xml.MarketPublishingStatus("12")
            end
            if supply[:availability_date]
            xml.MarketDate {
              xml.MarketDateRole("01")
              xml.DateFormat("00")
              xml.Date(supply[:availability_date].strftime("%Y%m%d"))
            }
            end
          }

          xml.SupplyDetail {
            xml.Supplier {
              xml.SupplierRole("03")
              if product.distributor

              if product.distributor_gln

              xml.SupplierIdentifier {
                xml.SupplierIDType("06")
                xml.IDValue(product.distributor_gln)
              }
              end
              xml.SupplierName(product.distributor_name)
              else
                  xml.SupplierName("Unknown")
              end
            }


            if supply[:available]
              xml.ProductAvailability("20")
            else
              xml.ProductAvailability("40")
            end

            supply[:prices].each do |price|
            xml.Price {
              if supply[:including_tax]
                xml.PriceType("04")
              else
                xml.PriceType("03")

              end
              xml.PriceAmount(price[:amount].to_f/100.0)
              xml.CurrencyCode(supply[:currency])

              if price[:from_date]
              xml.PriceDate {
                xml.PriceDateRole("14")
                xml.Date(price[:from_date].strftime("%Y%m%d"))
              }
              end
              if price[:until_date]
                xml.PriceDate {
                  xml.PriceDateRole("15")
                  xml.Date(price[:until_date].strftime("%Y%m%d"))
                }
              end
            }
            end
          }


        }

      end
      else
        xml.ProductSupply {
          xml.SupplyDetail {
            xml.Supplier {
              xml.SupplierRole("03")
              if product.distributor
                if product.distributor_gln
                  xml.SupplierIdentifier {
                    xml.SupplierIDType("06")
                    xml.IDValue(product.distributor_gln)
                  }
                end
                xml.SupplierName(product.distributor_name)
              else
                xml.SupplierName("Unknown")
              end

            }
            xml.ProductAvailability("45")
            xml.UnpricedItemType("03")
          }

        }

          end
      }
    end
  }
end

puts builder.to_xml

else
  puts "Onix 3.0 to Onix 3.0 converter"
  puts "Generate a flattened ONIX 3.0, be aware that conversion could be destructive"
  puts "Usage: onix3_to_onix3.rb onix.xml"
end
