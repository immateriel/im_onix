require 'helper'
require 'onix/serializer'

class TestContributor < Minitest::Test
  context "author with place informations" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/illustrations.xml")
      @product = @message.products.last
    end

    should "have author place" do
      assert_equal "US", @product.contributors.first.place.country_code
      assert_equal "BornIn", @product.contributors.first.place.relator.human
    end
  end

  context "author with date informations" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product = @message.products.last
    end

    should "have two dates" do
      assert_equal 2, @product.contributors.first.dates.length
    end

    should "have author birth date" do
      assert_equal Time.new(1989, 11, 9), @product.contributors.first.birth_date
    end

    should "have author death date" do
      assert_equal Time.new(2019, 9, 2), @product.contributors.first.death_date
    end
  end
end
