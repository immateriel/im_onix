module ONIX
  class Language < SubsetDSL
    element "LanguageRole", :subset, :shortcut => :role, :cardinality => 1
    element "LanguageCode", :subset, :shortcut => :code, :cardinality => 1
    element "CountryCode", :subset, :cardinality => 0..1
    element "RegionCode", :subset, :cardinality => 0..1
    element "ScriptCode", :subset, :cardinality => 0..1

    scope :of_text, lambda { human_code_match(:language_role, "LanguageOfText") }
    scope :of_original_text, lambda { human_code_match(:language_role, "OriginalLanguageOfATranslatedText") }
  end
end
