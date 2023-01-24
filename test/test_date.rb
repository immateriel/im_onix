require 'helper'
require 'onix/serializer'

class TestDate < Minitest::Test
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
end
