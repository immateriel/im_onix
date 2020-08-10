require 'helper'

class TestOnix2 < Minitest::Test
  context "ONIX 2.1" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/onix2.xml")
      @product = @message.products.last
    end

    should "have detected 2.1 version" do
      assert_equal 210, @message.version
    end

    should "have an EAN13" do
      assert_equal "9782346032532", @product.ean
    end

    should "have title" do
      assert_equal "La Physiologie de l'esprit", @product.title
    end

    should "have a main publisher named BnF-Partenariats" do
      assert_equal "BnF-Partenariats", @product.publisher_name
    end

    should "be priced in France" do
      assert_equal 149, @product.supplies_for_country("FR", "EUR").first[:prices].first[:amount]
    end

    should "have an excerpt with a link" do
      other_text_excerpt_code = "23"
      excerpt = @product.other_texts.select { |other_text| other_text.text_type_code.code == other_text_excerpt_code }[0]
      assert_equal "https://dummy.excerpt.link", excerpt.text_link
      assert_equal "01", excerpt.text_link_type
    end
  end

  context "ONIX 2.1 product only XML" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/onix2_product.xml")
      @product = @message.products.last
    end

    should "have detected 2.1 version" do
      assert_equal 210, @message.version
    end
  end

  context "wiley 2.1 xml file" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_wiley_data.xml")
      @product = @message.products.last
    end

    should "have an edition number" do
      assert_equal 1, @product.edition_number
    end

    should "have an EAN13" do
      assert_equal "9780470020043", @product.ean
    end

    should "have an ISBN-13" do
      assert_equal "9780470020043", @product.isbn13
    end

    should "have a frontcover_url" do
      assert_equal "http://TEST.com/images/db/jimages/9780470095003.jpg", @product.frontcover_url
    end
  end
end