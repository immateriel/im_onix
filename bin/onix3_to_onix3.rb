require 'im_onix'
require 'nokogiri'

filename=ARGV[0]

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

        # NOT HIGH LEVEL
        xml.ProductForm(product.descriptive_detail.form.code)

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

        # MISSING edition

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
        if product.publisher
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
      }

      xml.RelatedMaterial {
        if product.paper_linking
          xml.RelatedProduct {
            xml.ProductRelationCode("13")

            xml.ProductIdentifier {
              xml.ProductIDType("03")
              xml.IDValue(product.paper_linking.ean)
            }

          }
        end
      }

      product.supplies.each do |supply|
        xml.ProductSupply {
          xml.Market {
            xml.Territory {
              xml.CountriesIncluded(supply[:territory].join(" "))
            }
          }
          xml.MarketPublishingDetail {
            if supply[:available]
              xml.MarketPublishingStatus("04")
            else
              xml.MarketPublishingStatus("12")
            end
            xml.MarketDate {
              xml.MarketDateRole("01")
              xml.DateFormat("00")
              xml.Date(supply[:availability_date].strftime("%Y%m%d"))
            }
          }

          xml.SupplyDetail {
            if product.distributor
            xml.Supplier {
              xml.SupplierRole("03")
              if product.distributor_gln
              xml.SupplierIdentifier {
                xml.SupplierIDType("06")
                xml.IDValue(product.distributor_gln)
              }
              end
              xml.SupplierName(product.distributor_name)
            }
            else
              xml.Supplier {
                xml.SupplierName("Unknown")
              }
            end

            if supply[:available]
              xml.ProductAvailability("20")
            else
              xml.ProductAvailability("40")
            end

            supply[:prices].each do |price|
            xml.Price {
              if supply[:tax_included]
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
      }
    end
  }
end

puts builder.to_xml

