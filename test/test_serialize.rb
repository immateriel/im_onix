require 'helper'
require 'onix/serializer'

class TestSerialize < Minitest::Test

  context "ONIX file" do
    setup do
      @filename = "test/fixtures/reflowable.xml"
      @message = ONIX::ONIXMessage.new
      @message.parse(@filename)
    end

    should "be the same serialized" do
      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        ONIX::Serializer::Default::Subset.serialize(xml, "ONIXMessage", @message)
      end
      #      puts builder.to_xml
      assert_equal builder.to_xml, File.read(@filename)
    end
  end

end
