module ONIX
  class ProfessionalAffiliation < SubsetDSL
    elements "ProfessionalPosition", :text, :cardinality => 0..n
    element "Affiliation", :text, :cardinality => 0..1
  end
end
