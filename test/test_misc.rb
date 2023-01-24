# coding: utf-8
require 'helper'

class TestMisc < Minitest::Test
  context "certaines n'avaient jamais vu la mer" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product = @message.products.last
    end

    should "have detected 3.0 version" do
      assert_equal 300, @message.version
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
      assert_equal "PublishersNonExclusiveDistributorToRetailers", @product.distributors.first.role.human
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

    should "have some keywords" do
      assert_equal 11, @product.keywords.length
      assert_equal ["destin de femmes", "États-Unis d'Amérique", "Asie", "Oubli", "Amérique du Nord", "Guerre", "Prix Femina étranger 2012", "Exil", "Amérique", "Japon", "mariage forcé"], @product.keywords
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

    should "have corporate name" do
      assert_equal "Julie Otsuka", @product.contributors.first.corporate_name
    end

    should "have inverted corporate name" do
      assert_equal "Otsuka, Julie", @product.contributors.first.corporate_name_inverted
    end

    should "have author biography" do
      assert_equal "<p>Julie Otsuka est n&eacute;e en 1962 en Californie. Dipl&ocirc;m&eacute;e en art, elle abandonne une carri&egrave;re de peintre (elle a &eacute;tudi&eacute; cette discipline &agrave; l'universit&eacute; de Yale) pour l'&eacute;criture. Elle publie son premier roman en 2002, <em>Quand l'empereur &eacute;tait un dieu </em>(Ph&eacute;bus, 2004 ; 10/18, 2008) largement inspir&eacute; de la vie de ses grands-parents. Son deuxi&egrave;me roman, <em>Certaines n'avaient jamais vu la mer </em>(Ph&eacute;bus, 2012) a &eacute;t&eacute; consid&eacute;r&eacute; aux &Eacute;tats-Unis, d&egrave;s sa sortie, comme un chef-d'oeuvre. Julie Otsuka vit &agrave; New York.</p>", @product.contributors.first.biography
    end

    should "not have author place" do
      assert_nil @product.contributors.first.place
    end

    should "have supplier named" do
      assert_equal "immatériel·fr", @product.supplies_for_country("FR", "EUR").first[:suppliers].first
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

    should "have discount" do
      discount = @product.product_supplies.last.supply_details.last.prices.last.discount

      assert_equal "02", discount.code_type
      assert_equal "CSPLUS", discount.code_type_name
      assert_equal "04", discount.code
    end
  end

  context "file full-sender.xml" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/full-sender.xml")
      @product = @message.products.last
    end

    should "have a named sender with a GLN" do
      assert_equal "Hxxxxxxx Lxxxx", @message.sender.name
      assert_equal "42424242424242", @message.sender.gln
    end
  end

  context "multiple publishers" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782707154298.xml")
      @product = @message.products.last
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
      assert_equal "CoPublisher", @product.publishers.last.role.human
    end
  end

  # from ONIX documentation
  context "short tags" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/short.xml")
      @product = @message.products.last
    end

    should "have title" do
      assert_equal "Roseanna", @product.title
    end

    should "have publisher" do
      assert_equal 1, @product.publishers.length
      assert_equal "HarperCollins Publishers", @product.publisher_name
    end

    should "have two authors" do
      assert_equal 2, @product.contributors.select { |c| c.role.human == "ByAuthor" }.length
    end
  end

  context "with illustrations" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/illustrations.xml")
      @product = @message.products.last
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

end
