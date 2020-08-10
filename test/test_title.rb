require 'helper'

class TestTitle < Minitest::Test
  def create_title_detail(xml)
    message = ONIX::ONIXMessage.new.open(xml)
    detail = ONIX::TitleDetail.new
    detail.parse(message.root)
    detail
  end

  context "when it has a title element for level 1" do
    setup do
      @title_detail = create_title_detail <<XML
        <TitleDetail>
          <TitleType>01</TitleType>
          <TitleElement>
            <TitleElementLevel>02</TitleElementLevel>
            <TitleText><![CDATA[Hors Collection]]></TitleText>
          </TitleElement>
          <TitleElement>
            <TitleElementLevel>03</TitleElementLevel>
            <TitleText><![CDATA[Nom de Série]]></TitleText>
          </TitleElement>
          <TitleElement>
            <TitleElementLevel>01</TitleElementLevel>
            <TitleText><![CDATA[Le Titre]]></TitleText>
          </TitleElement>
        </TitleDetail>
XML
    end

    should "retrieve the title" do
      assert_equal "Le Titre", @title_detail.title
    end
  end

  context "when it has a title statement" do
    setup do
      @title_detail = create_title_detail <<XML
          <TitleDetail>
            <TitleType>01</TitleType>
            <TitleElement>
              <TitleElementLevel>01</TitleElementLevel>
              <TitleText><![CDATA[Le Titre]]></TitleText>
            </TitleElement>
            <TitleStatement><![CDATA[Le Titre à afficher]]></TitleStatement>
          </TitleDetail>
XML
    end

    should "retrieve the title from the title statement" do
      assert_equal "Le Titre à afficher", @title_detail.title
    end
  end
end
