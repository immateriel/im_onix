require 'helper'
require 'onix/serializer'

class TestTextformat < Minitest::Test

  context "no textformat" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/9782752906700.xml")
      @product = @message.products.last
    end

    should "have html description" do
      assert_equal "<p>Japon, 1919. Un bateau quitte l’Empire du Levant avec à son bord plusieurs dizaines de jeunes femmes promises à des Japonais travaillant aux États-Unis, toutes mariées par procuration. À la façon d’un chœur antique, leurs voix s'élèvent et racontent leurs misérables vies d’exilées... leur nuit de noces, souvent brutale, leurs rudes journées de travail dans les champs, leurs combats pour apprivoiser une langue inconnue, l’humiliation des Blancs, le rejet par leur progéniture de leur patrimoine et de leur histoire... Une véritable clameur jusqu’au silence de la guerre. Et l'oubli.</p>\n<p>\n  <strong>Prix Femina étranger 2012</strong>\n</p>", @product.description
    end
  end

  context "05 invalid textformat" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/invalid_textformat.xml")
      @product = @message.products.last
    end

    should "have html description" do
      assert_equal "<p>Japon, 1919. Un bateau quitte l’Empire du Levant avec à son bord plusieurs dizaines de jeunes femmes promises à des Japonais travaillant aux États-Unis, toutes mariées par procuration. À la façon d’un chœur antique, leurs voix s'élèvent et racontent leurs misérables vies d’exilées... leur nuit de noces, souvent brutale, leurs rudes journées de travail dans les champs, leurs combats pour apprivoiser une langue inconnue, l’humiliation des Blancs, le rejet par leur progéniture de leur patrimoine et de leur histoire... Une véritable clameur jusqu’au silence de la guerre. Et l'oubli.</p>\n<p>\n  <strong>Prix Femina étranger 2012</strong>\n</p>", @product.description
    end
  end

  context "05 valid textformat" do
    setup do
      @message = ONIX::ONIXMessage.new
      @message.parse("test/fixtures/full_sample.xml")
      @product = @message.products.last
    end

    should "have html description" do
      assert_equal "<p>Widely recognised as the among the greatest crime fiction ever written, this is the first of a series of stories that pioneered the police procedural genre. The series was translated into 35 languages, sold over 10 million copies around the world, and inspired writers from Henning Mankell to Jonathan Franzen.</p><p>Written in 1965, <em>Roseanna</em> is the work of Maj Sjöwall and Per Wahlöö – a husband and wife team from Sweden, and this volume has a new introduction to help bring their work to a new audience. The novel follows the fortunes of the detective Martin Beck, whose enigmatic and taciturn character has inspired countless other policemen in crime fiction.</p><p><em>Roseanna</em> begins on a July afternoon: the body of a young woman is dredged from a canal near Sweden’s beautiful Lake Vättern. Three months later, all that Police Inspector Martin Beck knows is that her name is Roseanna, that she came from Lincoln, Nebraska, and that she could have been strangled by any one of eighty-five people.</p><p>With its authentically rendered settings and vividly realized characters, and its command over the intricately woven details of police detection, <em>Roseanna</em> is a masterpiece of suspense and sadness.</p>", @product.description
    end
  end
end
