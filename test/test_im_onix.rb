# coding: utf-8
require 'helper'

class TestImOnix < Minitest::Test
  def test_products_discount
    message = ONIX::ONIXMessage.new
    message.parse("test/fixtures/9782752906700.xml")
    product = message.products.last
    discount = product.product_supplies.last.supply_details.last.prices.last.discount

    assert_equal "02", discount.code_type
    assert_equal "CSPLUS", discount.code_type_name
    assert_equal "04", discount.code
  end

  context "certaines n'avaient jamais vu la mer" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product=@message.products.last
    end

    should "have record reference" do
      assert_equal "immateriel.fr-O192530", @product.record_reference
    end

    should "have a named sender without GLN" do
      assert_equal "immatériel·fr", @message.sender.name
      assert_equal nil, @message.sender.gln
    end

    should "have an EAN13" do
      assert_equal "9782752908643", @product.ean
    end

    should "have a named proprietary id" do
      assert_equal 'O192530', @product.proprietary_ids.first.value
      assert_equal 'SKU', @product.proprietary_ids.first.name
    end

    should "have title" do
      assert_equal "Certaines n'avaient jamais vu la mer", @product.title
    end

    should "have no format" do
      assert_equal nil, @product.file_format
    end

    should "have publisher name" do
      assert_equal "Phébus", @product.publisher_name
    end

    should "be published" do
      assert_equal Date.new(2012,9,6), @product.publication_date
    end

    should "be in french" do
      assert_equal "fre", @product.language_code_of_text
    end

    should "be bundle" do
      assert_equal true, @product.bundle?
    end

    should "have parts" do
      assert_equal 3, @product.parts.length
    end

    should "have parts that do not provide info about fixed layout or not" do
      @product.parts.each do |part|
        assert_equal nil, part.reflowable?
      end
    end

    should "have a printed equivalent with a proprietary id" do
      print = @product.print_product
      assert_equal "9782752906700", print.ean
      assert_equal "RP64128-print", print.proprietary_ids.first.value
    end

    should "have a PDF equivalent" do
      pdf = @product.related_material.alternative_format_products.first
      assert_equal "9781111111111", pdf.ean
      assert_equal "Pdf", pdf.file_format
    end

    should "not provide info about fixed layout or not" do
      assert_equal nil, @product.reflowable?
    end

    should "have author named" do
      assert_equal "Julie Otsuka", @product.contributors.first.name
    end

    should "be available in France" do
      assert_equal true, @product.supplies_for_country("FR","EUR").first[:available]
    end

    should "be priced in France" do
      assert_equal 1099, @product.supplies_for_country("FR","EUR").first[:prices].first[:amount]
    end

    should "be available in Switzerland" do
      assert_equal true, @product.supplies_for_country("CH","CHF").first[:available]
    end

    should "be priced in Switzerland" do
      assert_equal 1400, @product.supplies_for_country("CH","CHF").first[:prices].first[:amount]
    end

    should "be a part of its main product" do
      parent = @product.part_of_product
      assert_equal "9782752908643", parent.ean
      assert_equal "O192530", parent.proprietary_ids.first.value
    end
  end

  context "reflowable epub" do
      setup do
        @message = ONIX::ONIXMessage.new
        @message.parse("test/fixtures/reflowable.xml")
        @product = @message.products.last
      end

      should "be reflowable" do
        assert_equal true, @product.reflowable?
      end
  end

  context "epub fixed layout" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/fixed_layout.xml")
      @product = @message.products.last
    end

    should "not be reflowable" do
      assert_equal false, @product.reflowable?
    end
  end

  context 'epub part of "Certaines n’avaient jamais vu la mer"' do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product=@message.products[1]
    end

    should "have epub file format" do
      assert_equal "Epub", @product.file_format
    end
  end

  context "prices with past change time" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices1.xml")
      @product=@message.products.last
    end

    should "be available in France" do
      assert_equal true, @product.supplies_for_country("FR","EUR").first[:available]
    end

    should "be currently priced in France" do
      assert_equal 1499, @product.current_price_amount_for("EUR","FR")
    end

    should "be priced in France at past date" do
      assert_equal 499, @product.at_time_price_amount_for(Time.new(2013,3,1),"EUR","FR")
    end

    should "be priced in France at change date" do
      assert_equal 1499, @product.at_time_price_amount_for(Time.new(2013,4,27),"EUR","FR")
    end

  end


  context "prices starting free with date" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices2.xml")
      @product=@message.products.last
    end

    should "be available in France" do
      assert_equal true, @product.supplies_for_country("FR","EUR").first[:available]
    end

    should "be currently priced in France" do
      assert_equal 399, @product.current_price_amount_for("EUR","FR")
    end

    should "be priced in France at future date" do
      assert_equal 399, @product.at_time_price_amount_for(Time.new(2013,12,1),"EUR","FR")
    end

    should "be priced in France at change date" do
      assert_equal 399, @product.at_time_price_amount_for(Time.new(2013,10,1),"EUR","FR")
    end

    should "be available in Switzerland" do
      assert_equal true, @product.supplies_for_country("CH","CHF").first[:available]
    end

    should "be currently priced in Switzerland" do
      assert_equal 500, @product.current_price_amount_for("CHF","CH")
    end

    should "be priced in Switzerland at future date" do
      assert_equal 500, @product.at_time_price_amount_for(Time.new(2013,12,1),"CHF","CH")
    end
  end

  context "prices with multiple product supplies and no until date" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices3.xml")
      @product=@message.products.last
    end

    should "be available in France" do
      assert_equal true, @product.supplies_for_country("FR","EUR").first[:available]
    end

    should "be currently priced in France" do
      assert_equal 199, @product.current_price_amount_for("EUR","FR")
    end

    should "be priced in France at past date" do
      assert_equal 299, @product.at_time_price_amount_for(Time.new(2013,5,1),"EUR","FR")
    end

    should "be priced in France at change date" do
      assert_equal 199, @product.at_time_price_amount_for(Time.new(2013,6,10),"EUR","FR")
    end

    should "be available in Switzerland" do
      assert_equal true, @product.supplies_for_country("CH","CHF").first[:available]
    end

    should "be currently priced in Switzerland" do
      assert_equal 250, @product.current_price_amount_for("CHF","CH")
    end

    should "be priced in Switzerland at past date" do
      assert_equal 400, @product.at_time_price_amount_for(Time.new(2013,5,1),"CHF","CH")
    end

    should "be priced in Switzerland at change date" do
      assert_equal 250, @product.at_time_price_amount_for(Time.new(2013,6,10),"CHF","CH")
    end

  end

  context "file full-sender.xml" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/full-sender.xml")
      @product=@message.products.last
    end

    should "have a named sender with a GLN" do
      assert_equal "Hxxxxxxx Lxxxx", @message.sender.name
      assert_equal "42424242424242", @message.sender.gln
    end
  end
end
