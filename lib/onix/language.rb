module ONIX
  class Language < SubsetDSL
    element "LanguageRole", :subset, :shortcut => :role
    element "LanguageCode", :subset, :shortcut => :code

    scope :of_text, lambda { human_code_match(:language_role, "LanguageOfText") }
  end
end
