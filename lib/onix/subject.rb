module ONIX
  class Subject < SubsetDSL
    element "MainSubject", :bool
    element "SubjectSchemeIdentifier", :subset, :shortcut => :scheme_identifier
    element "SubjectSchemeName", :text, :shortcut => :scheme_name
    element "SubjectSchemeVersion", :text, :shortcut => :scheme_version
    element "SubjectCode", :text, :shortcut => :code
    element "SubjectHeadingText", :text, :shortcut => :heading_text

    scope :bisac, lambda { human_code_match(:subject_scheme_identifier, "BisacSubjectHeading") }
    scope :clil, lambda { human_code_match(:subject_scheme_identifier, "Clil") }
    scope :keyword, lambda { human_code_match(:subject_scheme_identifier, "Keywords") }
  end
end