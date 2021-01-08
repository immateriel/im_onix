require 'helper'

class TestPrices < Minitest::Test
  context "prices with past change time" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices1.xml")
      @product = @message.products.last
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
      @product = @message.products.last
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
      @product = @message.products.last
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
      @product = @message.products.last
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
      @product = @message.products.last
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
      @product = @message.products.last
    end

    should "have a from date even if it's passed" do
      assert_equal Date.new(2013, 10, 01), @product.supplies(true).first[:prices].first[:from_date]
    end
  end

  context "price with multiple default EUR prices and only one EUR discount" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/test_prices6.xml")
      @product = @message.products.last
    end

    should "have only one EUR prices group" do
      assert_equal 1, @product.supplies.select { |s| s[:currency] == "EUR" }.count
    end
  end

  context "epub not yet available" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/price_to_be_announced.xml")
      @product = @message.products.last
    end

    should "have a price to be announced" do
      assert_equal true, @product.price_to_be_announced?
    end
  end

  context 'sales restriction of "Certaines n’avaient jamais vu la mer"' do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product = @message.products.first
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
end