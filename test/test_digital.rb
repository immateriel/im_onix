require 'helper'
require 'onix/serializer'

class TestDigital < Minitest::Test
  context 'streaming version of "Certaines n’avaient jamais vu la mer"' do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product = @message.products.first
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
      @product = @message.products[1]
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

  context "audio product specified as 'downloadable audio file'" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/audio1.xml")
      @product = @message.products.last
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
      @product = @message.products.last
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
      @product = @message.products.last
    end

    should "be a streaming product" do
      assert @product.streaming?
    end
  end

  context "with several protections in the same product" do
    setup do
      message = ONIX::ONIXMessage.new
      message.parse('test/fixtures/test_several_protections.xml')

      @product = message.products.last
    end

    should "have all the protections" do
      assert_equal ["AdobeDrm", "ReadiumLcpDrm"], @product.protections
    end
  end
end