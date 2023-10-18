require 'helper'

class TestAttributes < Minitest::Test
  context "full ONIX file" do
    setup do
      @filename = "test/fixtures/full_sample.xml"
      @message = ONIX::ONIXMessage.new
      @message.parse(@filename)
      @product = @message.products.first
    end

    should "contributor have xhtml text" do
      assert_equal 4, @product.contributors.count
      assert @product.contributors.first
      assert @product.contributors.first.biographical_notes
      assert @product.contributors.first.biographies
      assert @product.contributors.first.biographies_with_attributes
      assert_equal String, @product.contributors.first.biographies.first.class
      assert_equal ONIX::TextWithAttributes, @product.contributors.first.biographies_with_attributes.first.class
      assert @product.contributors.first.biographies_with_attributes.first.attributes["textformat"]
      assert_equal "Xhtml", @product.contributors.first.biographies_with_attributes.first.attributes["textformat"].human
    end

    should "have two languages (one for the current translated text and another for the original)" do
      assert_equal "eng", @product.language_code_of_text
      assert_equal "English", @product.language_name_of_text

      assert_equal "swe", @product.language_code_of_original_text
      assert_equal "Swedish", @product.language_name_of_original_text
    end
  end
end

