require 'helper'
require 'onix/serializer'
require 'onix/builder'

class TestSerialize < Minitest::Test

  context "simple ONIX file" do
    setup do
      @filename = "test/fixtures/reflowable.xml"
      @message = ONIX::ONIXMessage.new
      @message.parse(@filename)
    end

    should "find instance" do
      msg = ONIX::Builder.new
      @test_lang = "fre"

      msg.ONIXMessage("3.0") do
        Header do
          Sender do
            SenderName("immatériel·fr")
          end
          SentDateTime("20130802T000000+0200")
          DefaultLanguageOfText(@test_lang)
        end
      end
    end

    should "find method" do
      msg = ONIX::Builder.new

      msg.ONIXMessage("3.0") do
        Header do
          Sender do
            SenderName("immatériel·fr")
          end
          SentDateTime("20130802T000000+0200")
          DefaultLanguageOfText(test_lang)
        end
      end
    end

    should "be the same serialized" do
      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        ONIX::Serializer::Default.serialize(xml, @message)
      end
      assert_equal builder.to_xml, File.read(@filename)
    end

    should "invalid child raise exception" do
      assert_raises(ONIX::BuilderInvalidChildElement) do
        msg = ONIX::Builder.new
        msg.Header do
          SenderName("immatériel.fr")
        end
      end
    end

    should "invalid code raise exception" do
      assert_raises(ONIX::BuilderInvalidCode) do
        msg = ONIX::Builder.new
        msg.Product do
          NotificationType("NOTACODE")
        end
      end
    end

    should "invalid alias code raise exception" do
      assert_raises(ONIX::InvalidCodeAlias) do
        msg = ONIX::Builder.new
        msg.Product do
          NotificationType(:InvalidAlias)
        end
      end
    end

    should "collateral date" do
      msg = ONIX::Builder.new
      msg.Product {
        RecordReference("AAA")
        NotificationType("03")
        CollateralDetail {
          SupportingResource {
            ResourceContentType("01")
            ContentAudience("00")
            ResourceMode("03")
            ResourceVersion {
              ResourceForm("02")
              ResourceLink("http://images.immateriel.fr/link")

              ContentDate {
                ContentDateRole("17")
                DateFormat("00")
                Date(Date.today)
              }
            }
          }
        }
      }

      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        msg.to_xml(xml)
      end

      builder.to_xml

    end

    should "be the same with builder" do
      msg = ONIX::Builder.new

      msg.ONIXMessage("3.0") do
        Header do
          Sender do
            SenderName("immatériel·fr")
          end
          SentDateTime("20130802T000000+0200")
          DefaultLanguageOfText("fre")
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

  context "full ONIX file" do
    setup do
      @filename = "test/fixtures/full_sample.xml"
      @message = ONIX::ONIXMessage.new
      @message.parse(@filename)
      @product = @message.products.first
    end
    should "be the same serialized" do
      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        ONIX::Serializer::Default.serialize(xml, @message)
      end
      #assert_equal builder.to_xml, File.read(@filename)
      assert_equal builder.to_xml.gsub(/\>\s+\</, "><"), File.read(@filename).gsub(/\>\s+\</, "><")
    end
  end

  def test_lang
    "fre"
  end
end
