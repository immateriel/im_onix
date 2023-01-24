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
      @test_lang = "fre"
      builder = ONIX::Builder.new do |onix|
        onix.ONIXMessage("3.0") do
          onix.Header do
            onix.Sender do
              onix.SenderName("immatériel·fr")
            end
            onix.SentDateTime("20130802T000000+0200")
            onix.DefaultLanguageOfText(@test_lang)
          end
        end
      end
    end

    should "find method" do
      builder = ONIX::Builder.new do |onix|
        onix.ONIXMessage("3.0") do
          onix.Header do
            onix.Sender do
              onix.SenderName("immatériel·fr")
            end
            onix.SentDateTime("20130802T000000+0200")
            onix.DefaultLanguageOfText(test_lang)
          end
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
        builder = ONIX::Builder.new do |onix|
          onix.Header do
            onix.SenderName("immatériel.fr")
          end
        end
      end
    end

    should "undefined element raise exception" do
      assert_raises(ONIX::BuilderInvalidChildElement) do
        builder = ONIX::Builder.new do |onix|
          onix.Product do
            onix.UndefinedElement(:InvalidAlias)
          end
        end
      end
    end

    should "invalid code raise exception" do
      assert_raises(ONIX::BuilderInvalidCode) do
        builder = ONIX::Builder.new do |onix|
          onix.Product do
            onix.NotificationType("NOTACODE")
          end
        end
      end
    end

    should "invalid code lax" do
      builder = ONIX::Builder.new do |onix|
        onix.Product do
          assert_raises(ONIX::BuilderInvalidCode) do
            onix.NotificationType("NOTACODE")
          end
          onix.lax do
            onix.NotificationType("NOTACODE")
          end
          assert_raises(ONIX::BuilderInvalidCode) do
            onix.NotificationType("NOTACODE")
          end
        end
      end
    end

    should "invalid alias code raise exception" do
      assert_raises(ONIX::InvalidCodeAlias) do
        builder = ONIX::Builder.new do |onix|
          onix.Product do
            onix.NotificationType(:InvalidAlias)
          end
        end
      end
    end

    should "collateral date" do
      builder = ONIX::Builder.new do |onix|
        onix.Product {
          onix.RecordReference("AAA")
          onix.NotificationType("03")
          onix.CollateralDetail {
            onix.SupportingResource {
              onix.ResourceContentType("01")
              onix.ContentAudience("00")
              onix.ResourceMode("03")
              onix.ResourceVersion {
                onix.ResourceForm("02")
                onix.ResourceLink("http://images.immateriel.fr/link")

                onix.ContentDate {
                  onix.ContentDateRole("17")
                  onix.DateFormat("05")
                  onix.Date(Date.today)
                }
              }
            }
          }
          onix.PublishingDetail {
            onix.Imprint {
              onix.ImprintName("Imprint", sourcename: "SOURCENAME", sourcetype: "00")
            }
          }
        }
      end

      # puts builder.to_xml
      assert builder.to_xml
    end

    should "be the same with builder" do
      builder = ONIX::Builder.new do |onix|
        onix.ONIXMessage("3.0") do
          onix.Header do
            onix.Sender do
              onix.SenderName("immatériel·fr")
            end
            onix.SentDateTime("20130802T000000+0200")
            onix.DefaultLanguageOfText("fre")
          end
          onix.Product do
            onix.RecordReference("immateriel.fr-RP64127")
            onix.NotificationType("03")
            onix.ProductIdentifier do
              onix.ProductIDType("01")
              onix.IDValue("RP64127")
            end
            onix.ProductIdentifier do
              onix.ProductIDType("03")
              onix.IDValue("3019002489901")
            end
            onix.DescriptiveDetail do
              onix.ProductComposition("00")
              onix.ProductForm("ED")
              onix.ProductFormDetail("E101")
              onix.ProductFormDetail("E200")
              onix.ProductFormDescription("ePub avec Tatouage")
              onix.ProductContentType("10")
              onix.EpubTechnicalProtection("02")
              onix.EpubUsageConstraint do
                onix.EpubUsageType("02")
                onix.EpubUsageStatus("01")
              end
              onix.EpubUsageConstraint do
                onix.EpubUsageType("03")
                onix.EpubUsageStatus("01")
              end
              onix.EpubUsageConstraint do
                onix.EpubUsageType("04")
                onix.EpubUsageStatus("01")
              end
              onix.TitleDetail do
                onix.TitleType("01")
                onix.TitleElement do
                  onix.TitleElementLevel("01")
                  onix.TitleText("Certaines n'avaient jamais vu la mer")
                end
              end
              onix.Extent do
                onix.ExtentType("22")
                onix.ExtentValue("480211")
                onix.ExtentUnit("17")
              end
            end
            onix.RelatedMaterial do
              onix.RelatedProduct do
                onix.ProductRelationCode("02")
                onix.ProductIdentifier do
                  onix.ProductIDType("01")
                  onix.IDValue("O192530")
                end
                onix.ProductIdentifier do
                  onix.ProductIDType("03")
                  onix.IDValue("9782752908643")
                end
                onix.ProductIdentifier do
                  onix.ProductIDType("15")
                  onix.IDValue("9782752908643")
                end
              end
            end

            onix.ProductSupply do
              onix.SupplyDetail do
                onix.Supplier do
                  onix.SupplierRole("03")
                  onix.SupplierIdentifier do
                    onix.SupplierIDType("02")
                    onix.IDValue("D1")
                  end
                  onix.SupplierIdentifier do
                    onix.SupplierIDType("06")
                    onix.IDValue("3012410001000")
                  end
                  onix.SupplierName("immatériel·fr")
                end
                onix.ProductAvailability("45")
                onix.UnpricedItemType("03")
              end
            end
          end
        end
      end

      assert_equal File.read(@filename), builder.to_xml
    end
  end

  context "ONIX file" do
    setup do
      @filename = "test/fixtures/test_YYYY_date_format.xml"
      @message = ONIX::ONIXMessage.new
      @message.parse(@filename)
      @product = @message.products.first
    end
    should "be the same serialized" do
      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        ONIX::Serializer::Default.serialize(xml, @product, "Product")
      end
      assert_equal File.read(@filename), builder.to_xml.sub("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", "")
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
      assert_equal Nokogiri::XML.parse(File.read(@filename), &:noblanks).to_xml, Nokogiri::XML.parse(builder.to_xml, &:noblanks).to_xml
    end
  end

  def test_lang
    "fre"
  end
end
