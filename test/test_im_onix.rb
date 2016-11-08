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

    should "have an ISBN-13" do
      assert_equal "9782752908643", @product.isbn13
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

    should "have no format details" do
      assert_equal [], @product.form_details
    end

    should "have one publisher named Phébus" do
      assert_equal 1, @product.publishers.length
      assert_equal "Phébus", @product.publisher_name
      assert_equal "Publisher", @product.publishers.first.role.human
    end

    should "have one publisher GLN" do
      assert_equal "3052859400019", @product.publisher_gln
    end

    should "have one distributor named immatériel·fr" do
      assert_equal 1, @product.distributors.length
      assert_equal "immatériel·fr", @product.distributor_name
      assert_equal "PublishersNonexclusiveDistributorToRetailers", @product.distributors.first.role.human
    end

    should "have one distributor GLN" do
      assert_equal "3012410001000", @product.distributor_gln
    end

    should "have a main publisher named Phébus" do
      assert_equal "Phébus", @product.publishing_detail.publisher.name
    end

    should "be published" do
      assert_equal Date.new(2012,9,6), @product.publication_date
    end

    should "be no embargo date" do
      assert_equal nil, @product.embargo_date
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

    should "have author inverted named" do
      assert_equal "Otsuka, Julie", @product.contributors.first.inverted_name
    end

    should "not have author place" do
      assert_nil @product.contributors.first.place
    end

    should "have supplier named" do
      assert_equal "immatériel·fr", @product.supplies_for_country("FR","EUR").first[:suppliers].first.name
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
  end

  context 'streaming version of "Certaines n’avaient jamais vu la mer"' do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product=@message.products.first
    end

    should "be streaming" do
      assert @product.streaming?
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

    should "have format details" do
      assert_equal 2, @product.form_details.length
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

    should "be a part of its main product" do
      parent = @product.part_of_product
      assert_equal "9782752908643", parent.ean
      assert_equal "O192530", parent.proprietary_ids.first.value
    end

    should "have format details" do
      assert_equal 1, @product.form_details.length
    end
  end

  context "author with place informations" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/illustrations.xml")
      @product=@message.products.last
    end

    should "have author place" do
      assert_equal "US", @product.contributors.first.place.country_code
      assert_equal "BornIn", @product.contributors.first.place.relator.human
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

  context "price with tax" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices4.xml")
      @product=@message.products.last
    end

    should "have a tax amount and a tax rate" do
      assert_equal 109, @product.supplies_for_country('FR','EUR').first[:prices].first[:tax].amount
      assert_equal 5.5, @product.supplies_for_country('FR','EUR').first[:prices].first[:tax].rate_percent
    end

  end

  context "prices without taxes" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices1.xml")
      @product=@message.products.last
    end

    should "not have a tax" do
      assert_nil @product.supplies_for_country('FR','EUR').first[:prices].first[:tax]
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

  context "audio product specified as 'downloadable audio file'" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/audio1.xml")
      @product=@message.products.last
    end

    should "be an audio product" do
      assert @product.audio?
    end

    should "be an Mp3Format product" do
      assert_equal "Mp3Format", @product.audio_format
    end

  end

  context "audio product specified as 'digital content delivered by download only'" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/audio2.xml")
      @product=@message.products.last
    end

    should "be an audio product" do
      assert @product.audio?
    end

    should "be an Mp3Format product" do
      assert_equal "Mp3Format", @product.audio_format
    end

  end

  context "streaming epub" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/streaming.xml")
      @product=@message.products.last
    end

    should "be a streaming product" do
      assert @product.streaming?
    end
  end

  context "epub with one epub sample" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product=@message.products.last
    end

    should "have an URL to a downloadable excerpt" do
      assert_equal 'http://telechargement.immateriel.fr/fr/web_service/preview/12279/epub-preview.epub', @product.excerpts.first[:url]
      assert_equal 'Epub', @product.excerpts.first[:format_code]
      assert_equal 'DownloadableFile', @product.excerpts.first[:form]
      assert_equal 'e32ef9a1c1e63c96567b542f6e691530', @product.excerpts.first[:md5]
      assert_equal '20121015T220000+0000', @product.excerpts.first[:updated_at]
    end

    should "have 1 sample URL" do
      assert_equal 1, @product.excerpts.size
    end
  end

  context "book with several samples, including 2 URLs and 1 image" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/streaming.xml")
      @product=@message.products.last
    end

    should "have 2 sample URL" do
      assert_equal 2, @product.excerpts.size
    end

    should "have an URL to a downloadable excerpt" do
      assert_equal '9780000000000_preview.epub', @product.excerpts.first[:url]
      assert_equal 'DownloadableFile', @product.excerpts.first[:form]
      assert_equal nil, @product.excerpts.first[:md5]
    end

    should "have an URL to an embeddable application excerpt" do
      assert_equal 'http://www.xxxxxxx.com/preview-9780000000000-XXXXX', @product.excerpts.last[:url]
      assert_equal 'EmbeddableApplication', @product.excerpts.last[:form]
      assert_equal nil, @product.excerpts.last[:md5]
    end
  end

  context "book without any sample" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782707154298.xml")
      @product=@message.products.last
    end

    should "have 0 sample URL" do
      assert_equal 0, @product.excerpts.size
    end
  end

  context "multiple publishers" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782707154298.xml")
      @product=@message.products.last
    end

    should "have two publisher" do
      assert_equal 2, @product.publishers.length
      assert_equal "LA BALLE / Le ballon", @product.publisher_name
    end

    should "have a main publisher named LA BALLE" do
      assert_equal "LA BALLE", @product.publishing_detail.publisher.name
    end

    should "have a co-publisher named Le ballon" do
      assert_equal "Le ballon", @product.publishers.last.name
      assert_equal "Copublisher", @product.publishers.last.role.human
    end
  end

  # from ONIX documentation
  context "short tags" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/short.xml")
      @product=@message.products.last
    end

    should "have title" do
      assert_equal "Roseanna", @product.title
    end

    should "have publisher" do
      assert_equal 1, @product.publishers.length
      assert_equal "HarperCollins Publishers", @product.publisher_name
    end

    should "have two authors" do
      assert_equal 2, @product.contributors.select{|c| c.role.human=="ByAuthor"}.length
    end

  end

  context "other publication date format" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/other-publication-date-format.xml')

      @product = message.products.last
    end

    should "be published" do
      assert_equal Date.new(2011, 8, 31), @product.publication_date
    end

    should "be no embargo date" do
      assert_equal nil, @product.embargo_date
    end
  end

  context "with embargo date" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/embargo-date.xml')

      @product = message.products.last
    end

    should "be published" do
      assert_equal Date.new(2011, 8, 31), @product.publication_date
    end

    should "be no embargo date" do
      assert_equal Date.new(2012, 9, 21), @product.embargo_date
    end
  end

  context "with preorder embargo date" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/preorder-embargo-date.xml')

      @product = message.products.last
    end

    should "be published" do
      assert_equal Date.new(2011, 8, 31), @product.publication_date
    end

    should "have a preorder embargo date" do
      assert_equal Date.new(2011, 8, 21), @product.preorder_embargo_date
    end
  end

  context "epub with illustrations" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/illustrations.xml")
      @product=@message.products.last
    end

    should "have a front cover illustration with a last update date printed in UTC" do
      assert_equal @product.illustrations.first[:type], 'FrontCover'
      assert_equal @product.illustrations.first[:caption], 'Couverture principale'
      assert_equal @product.illustrations.first[:updated_at], '20121104T230000+0000'
    end

    should "have a publisher logo illustration" do
      assert_equal @product.illustrations.last[:type], 'PublisherLogo'
    end
  end

  context 'sales restriction of "Certaines n’avaient jamais vu la mer"' do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product=@message.products.first
    end

    should "be 09" do
      assert_equal "09", @product.sales_restriction.type.code
    end
  end
end
