require 'helper'

class TestCollection < Minitest::Test
  context "type" do
    setup do
      xml = ONIX::ONIXMessage.new.open("test/fixtures/test_collection.xml")
      @collection = ONIX::Collection.new
      @collection.parse(xml.root)
    end

    should "have a type" do
      assert_equal "10", @collection.type.code
    end

    should "have identifiers" do
      assert_equal "237", @collection.identifiers.first.value
    end

    should "have a sequence" do
      assert_equal "3", @collection.sequences.first.number
    end
  end
end
