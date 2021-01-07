require 'helper'
require 'onix/serializer'

class TestSerialize < Minitest::Test
  context "epub with one epub sample" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product = @message.products.last
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
      @product = @message.products.last
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
      @product = @message.products.last
    end

    should "have 0 sample URL" do
      assert_equal 0, @product.excerpts.size
    end
  end
end
