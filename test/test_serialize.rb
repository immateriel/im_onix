require 'helper'
require 'onix/serializer'
require 'onix/builder'

class TestSerialize < Minitest::Test

  context "ONIX file" do
    setup do
      @filename = "test/fixtures/reflowable.xml"
      @message = ONIX::ONIXMessage.new
      @message.parse(@filename)
    end

    should "be the same serialized" do
      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        ONIX::Serializer::Default::Subset.serialize(xml, "ONIXMessage", @message)
      end
      assert_equal builder.to_xml, File.read(@filename)
    end

    should "be the same with builder" do
      msg = ONIX::Builder.new

      msg.ONIXMessage do
        Header do
          Sender do
            SenderName("immatériel·fr")
          end
          #SentDateTime("20130802") # TODO
          DefaultLanguageOfText("fre") # TODO
        end
        Product do
          RecordReference("immateriel.fr-RP64127")
          NotificationType("03")
          ProductIdentifier do
            ProductIDType("01")
            IDValue("RP64127")
          end
          ProductIdentifier do
            ProductIDType("03")
            IDValue("3019002489901")
          end
          DescriptiveDetail do
            ProductComposition("00")
            ProductForm("ED")
            ProductFormDetail("E101")
            ProductFormDetail("E200")
            ProductFormDescription("ePub avec Tatouage")
            ProductContentType("10")
            EpubTechnicalProtection("02")
            EpubUsageConstraint do
              EpubUsageType("02")
              EpubUsageStatus("01")
            end
            EpubUsageConstraint do
              EpubUsageType("03")
              EpubUsageStatus("01")
            end
            EpubUsageConstraint do
              EpubUsageType("04")
              EpubUsageStatus("01")
            end
            TitleDetail do
              TitleType("01")
              TitleElement do
                TitleElementLevel("01")
                TitleText("Certaines n'avaient jamais vu la mer")
              end
            end
            Extent do
              ExtentType("22")
              ExtentValue("480211")
              ExtentUnit("17")
            end
          end

          RelatedMaterial do
            RelatedProduct do
              ProductRelationCode("02")
              ProductIdentifier do
                ProductIDType("01")
                IDValue("O192530")
              end
              ProductIdentifier do
                ProductIDType("03")
                IDValue("9782752908643")
              end
              ProductIdentifier do
                ProductIDType("15")
                IDValue("9782752908643")
              end
            end
          end

          ProductSupply do
            SupplyDetail do
              Supplier do
                if false # TODO
                SupplierRole("03")
                SupplierIdentifier do
                  SupplierIDType("02")
                  IDValue("D1")
                end
                SupplierIdentifier do
                  SupplierIDType("06")
                  IDValue("3012410001000")
                end
                SupplierName("immatériel·fr")
                end
              end
              ProductAvailability("45")
              UnpricedItemType("03")
            end
          end
        end
      end

      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        msg.to_xml(xml)
      end

      assert_equal builder.to_xml, File.read(@filename)
    end
  end

end
