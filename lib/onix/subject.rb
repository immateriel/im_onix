module ONIX
  class Subject < SubsetDSL
    element "MainSubject", :bool, :cardinality => 0..1
    element "SubjectSchemeIdentifier", :subset, :shortcut => :scheme_identifier, :cardinality => 1
    element "SubjectSchemeName", :text, :shortcut => :scheme_name, :cardinality => 0..1
    element "SubjectSchemeVersion", :text, :shortcut => :scheme_version, :cardinality => 0..1
    element "SubjectCode", :text, :shortcut => :code, :cardinality => 0..1
    elements "SubjectHeadingText", :text, :shortcut => :heading_texts, :cardinality => 0..n

    def heading_text
      self.heading_texts.first
    end

    scope :bisac, lambda { human_code_match(:subject_scheme_identifier, "BisacSubjectHeading") }
    scope :clil, lambda { human_code_match(:subject_scheme_identifier, "Clil") }
    scope :keyword, lambda { human_code_match(:subject_scheme_identifier, "Keywords") }
  end
end