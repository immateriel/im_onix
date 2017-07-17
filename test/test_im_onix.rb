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

  context "wiley 2.1 xml file" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_wiley_data.xml")
      @product=@message.products.last
    end

    should "have an edition number" do
      assert_equal 1, @product.edition_number
    end

    should "have a frontcover_url" do
      assert_equal "http://TEST.com/images/db/jimages/9780470095003.jpg", @product.frontcover_url
    end
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

    should "have an edition number" do
      assert_equal 1, @product.edition_number
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

    should "have one imprint named Phébus" do
      assert_equal "Phébus", @product.imprint_name
    end

    should "have one imprint GLN" do
      assert_equal "3052859400019", @product.imprint_gln
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
      assert_equal Date.new(2012, 9, 6), @product.publication_date
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

    should "have name before key" do
      assert_equal "Julie", @product.contributors.first.name_before_key
    end

    should "have author biography" do
      assert_equal "<p>Julie Otsuka est n&eacute;e en 1962 en Californie. Dipl&ocirc;m&eacute;e en art, elle abandonne une carri&egrave;re de peintre (elle a &eacute;tudi&eacute; cette discipline &agrave; l'universit&eacute; de Yale) pour l'&eacute;criture. Elle publie son premier roman en 2002, <em>Quand l'empereur &eacute;tait un dieu </em>(Ph&eacute;bus, 2004 ; 10/18, 2008) largement inspir&eacute; de la vie de ses grands-parents. Son deuxi&egrave;me roman, <em>Certaines n'avaient jamais vu la mer </em>(Ph&eacute;bus, 2012) a &eacute;t&eacute; consid&eacute;r&eacute; aux &Eacute;tats-Unis, d&egrave;s sa sortie, comme un chef-d'oeuvre. Julie Otsuka vit &agrave; New York.</p>", @product.contributors.first.biography
    end

    should "not have author place" do
      assert_nil @product.contributors.first.place
    end

    should "have supplier named" do
      assert_equal "immatériel·fr", @product.supplies_for_country("FR", "EUR").first[:suppliers].first.name
    end

    should "be available in France" do
      assert_equal true, @product.supplies_for_country("FR", "EUR").first[:available]
    end

    should "be priced in France" do
      assert_equal 1099, @product.supplies_for_country("FR", "EUR").first[:prices].first[:amount]
    end

    should "be available in Switzerland" do
      assert_equal true, @product.supplies_for_country("CH", "CHF").first[:available]
    end

    should "be priced in Switzerland" do
      assert_equal 1400, @product.supplies_for_country("CH", "CHF").first[:prices].first[:amount]
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
      assert_equal true, @product.supplies_for_country("FR", "EUR").first[:available]
    end

    should "be currently priced in France" do
      assert_equal 1499, @product.current_price_amount_for("EUR", "FR")
    end

    should "be priced in France at past date" do
      assert_equal 499, @product.at_time_price_amount_for(Time.new(2013, 3, 1), "EUR", "FR")
    end

    should "be priced in France at change date" do
      assert_equal 1499, @product.at_time_price_amount_for(Time.new(2013, 4, 27), "EUR", "FR")
    end

    should "not have a price to be announced" do
      assert_equal false, @product.price_to_be_announced?
    end
  end


  context "prices starting free with date" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices2.xml")
      @product=@message.products.last
    end

    should "be available in France" do
      assert_equal true, @product.supplies_for_country("FR", "EUR").first[:available]
    end

    should "be currently priced in France" do
      assert_equal 399, @product.current_price_amount_for("EUR", "FR")
    end

    should "be priced in France at future date" do
      assert_equal 399, @product.at_time_price_amount_for(Time.new(2013, 12, 1), "EUR", "FR")
    end

    should "be priced in France at change date" do
      assert_equal 399, @product.at_time_price_amount_for(Time.new(2013, 10, 1), "EUR", "FR")
    end

    should "be available in Switzerland" do
      assert_equal true, @product.supplies_for_country("CH", "CHF").first[:available]
    end

    should "be currently priced in Switzerland" do
      assert_equal 500, @product.current_price_amount_for("CHF", "CH")
    end

    should "be priced in Switzerland at future date" do
      assert_equal 500, @product.at_time_price_amount_for(Time.new(2013, 12, 1), "CHF", "CH")
    end

    should "not have a price to be announced" do
      assert_equal false, @product.price_to_be_announced?
    end
  end

  context "prices with multiple product supplies and no until date" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices3.xml")
      @product=@message.products.last
    end

    should "be available in France" do
      assert_equal true, @product.supplies_for_country("FR", "EUR").first[:available]
    end

    should "be currently priced in France" do
      assert_equal 199, @product.current_price_amount_for("EUR", "FR")
    end

    should "be priced in France at past date" do
      assert_equal 299, @product.at_time_price_amount_for(Time.new(2013, 5, 1), "EUR", "FR")
    end

    should "be priced in France at change date" do
      assert_equal 199, @product.at_time_price_amount_for(Time.new(2013, 6, 10), "EUR", "FR")
    end

    should "be available in Switzerland" do
      assert_equal true, @product.supplies_for_country("CH", "CHF").first[:available]
    end

    should "be currently priced in Switzerland" do
      assert_equal 250, @product.current_price_amount_for("CHF", "CH")
    end

    should "be priced in Switzerland at past date" do
      assert_equal 400, @product.at_time_price_amount_for(Time.new(2013, 5, 1), "CHF", "CH")
    end

    should "be priced in Switzerland at change date" do
      assert_equal 250, @product.at_time_price_amount_for(Time.new(2013, 6, 10), "CHF", "CH")
    end

    should "not have a price to be announced" do
      assert_equal false, @product.price_to_be_announced?
    end
  end

  context "price with tax" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices4.xml")
      @product=@message.products.last
    end

    should "have a tax amount and a tax rate" do
      assert_equal 109, @product.supplies_for_country('FR', 'EUR').first[:prices].first[:tax].amount
      assert_equal 5.5, @product.supplies_for_country('FR', 'EUR').first[:prices].first[:tax].rate_percent
    end

    should "not have a price to be announced" do
      assert_equal false, @product.price_to_be_announced?
    end
  end

  context "prices without taxes" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices1.xml")
      @product=@message.products.last
    end

    should "not have a tax" do
      assert_nil @product.supplies_for_country('FR', 'EUR').first[:prices].first[:tax]
    end

    should "not have a price to be announced" do
      assert_equal false, @product.price_to_be_announced?
    end
  end

  context "price with past from date" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices5.xml")
      @product=@message.products.last
    end

    should "have a from date even if it's passed" do
      assert_equal Time.new(2013, 10, 01), @product.supplies(true).first[:prices].first[:from_date]
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
      assert_equal 2, @product.contributors.select { |c| c.role.human=="ByAuthor" }.length
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
      assert_equal 'FrontCover', @product.illustrations.first[:type]
      assert_equal 'Couverture principale', @product.illustrations.first[:caption]
      assert_equal '20121104T230000+0000', @product.illustrations.first[:updated_at]
    end

    should "have a publisher logo illustration" do
      assert_equal 'PublisherLogo', @product.illustrations.last[:type]
    end

    should "have 2 illustrations" do
      assert_equal 2, @product.illustrations.size
    end
  end

  context "epub not yet available" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/price_to_be_announced.xml")
      @product=@message.products.last
    end

    should "have a price to be announced" do
      assert_equal true, @product.price_to_be_announced?
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

  context "with only from date" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/test_prices_with_only_from_date.xml')

      @product = message.products.last
    end

    should "have one supply with 2 price application periods" do
      assert_equal 1, @product.supplies.size

      prices = @product.supplies.first[:prices]

      assert_equal 2, prices.size

      # the first one: 8.99 € (default price) until 2016-07-07
      assert_equal 899, prices[0][:amount]
      assert_equal nil, prices[0][:from_date]
      assert_equal Date.new(2016, 7, 7), prices[0][:until_date]

      # the second one: 4.99 € from 2016-07-08
      assert_equal 499, prices[1][:amount]
      assert_equal Date.new(2016, 7, 8), prices[1][:from_date]
      assert_equal nil, prices[1][:until_date]
    end
  end

  context "with only until date" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/test_prices_with_only_until_date.xml')

      @product = message.products.last
    end

    should "have one supply with 2 price application periods" do
      assert_equal 1, @product.supplies.size

      prices = @product.supplies.first[:prices]

      assert_equal 2, prices.size

      # the first one: 4.99 € until 2016-07-07
      assert_equal 499, prices[0][:amount]
      assert_equal nil, prices[0][:from_date]
      assert_equal Date.new(2016, 7, 7), prices[0][:until_date]

      # the second one: 8.99 € (default price) from 2016-07-08
      assert_equal 899, prices[1][:amount]
      assert_equal Date.new(2016, 7, 8), prices[1][:from_date]
      assert_equal nil, prices[1][:until_date]
    end
  end

  context "with multiple dates and prices" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/test_prices_with_multiple_periods.xml')

      @product = message.products.last
    end

    should "have one supply with 5 price application periods" do
      assert_equal 1, @product.supplies.size

      prices = @product.supplies.first[:prices]

      assert_equal 5, prices.size

      # the first one: 8.99 € (default price) until 2016-07-07
      assert_equal 899, prices[0][:amount]
      assert_equal nil, prices[0][:from_date]
      assert_equal Date.new(2016, 7, 7), prices[0][:until_date]

      # the second one: 4.99 € (promo 1) from 2016-07-08 to 2016-07-08 (single day)
      assert_equal 499, prices[1][:amount]
      assert_equal Date.new(2016, 7, 8), prices[1][:from_date]
      assert_equal Date.new(2016, 7, 8), prices[1][:until_date]

      #the third one: 8.99 € (default price) from 2016-07-09 to 2016-07-31
      assert_equal 899, prices[2][:amount]
      assert_equal Date.new(2016, 7, 9), prices[2][:from_date]
      assert_equal Date.new(2016, 7, 31), prices[2][:until_date]

      #the fourth one: 3.99 € (promo 2) from 2016-08-01 to 2016-08-15
      assert_equal 399, prices[3][:amount]
      assert_equal Date.new(2016, 8, 1), prices[3][:from_date]
      assert_equal Date.new(2016, 8, 15), prices[3][:until_date]

      #the fifth one: 8.99 € (default) from 2016-08-16
      assert_equal 899, prices[4][:amount]
      assert_equal Date.new(2016, 8, 16), prices[4][:from_date]
      assert_equal nil, prices[4][:until_date]
    end
  end

  context "unqualified (default) prices and a single promotional offer price" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/unqualified-prices.xml')

      @product = message.products.last
    end

    should "have one supply with 3 price application periods" do
      assert_equal 1, @product.supplies.size

      prices = @product.supplies.first[:prices]

      assert_equal 3, prices.size

      # the first one: 8.99 € (default price) until 2016-07-07
      assert_equal 899, prices[0][:amount]
      assert_equal 'UnqualifiedPrice', prices[0][:qualifier]
      assert_equal nil, prices[0][:from_date]
      assert_equal Date.new(2016, 7, 7), prices[0][:until_date]

      # the second one: 4.99 € (promotional price) from 2016-07-08 to 2016-07-08 (single day)
      assert_equal 499, prices[1][:amount]
      assert_equal 'PromotionalOfferPrice', prices[1][:qualifier]
      assert_equal Date.new(2016, 7, 8), prices[1][:from_date]
      assert_equal Date.new(2016, 7, 8), prices[1][:until_date]

      # the third one: 8.99 € (default price) from 2016-07-09
      assert_equal 899, prices[2][:amount]
      assert_equal 'UnqualifiedPrice', prices[2][:qualifier]
      assert_equal Date.new(2016, 7, 9), prices[2][:from_date]
      assert_equal nil, prices[2][:until_date]
    end
  end

  context "with illustration last updated date" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/bad_content_date_format.xml')

      @product = message.products.last
    end

    should "have no last updated date for its illustration" do
      assert_equal 1, @product.illustrations.size
      assert_equal nil, @product.illustrations[0][:updated_at]
    end
  end

  context "ONIX 2.1" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/onix2.xml")
      @product=@message.products.last
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
  end

  context "with YYYY date format" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/test_YYYY_date_format.xml')

      @product = message.products.last
    end

    should "have a correct date format" do
      assert_equal Date.new(1989, 01, 01), @product.publication_date
    end
  end

  context "with several protections in the same product" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/test_several_protections.xml')

      @product = message.products.last
    end

    should "have all the protections" do
      assert_equal ["AdobeDrm", "Readium LCP DRM"], @product.protections
    end
  end
end
