module ONIX
  class CopyrightStatement < SubsetDSL
    element "CopyrightType", :subset, :cardinality => 0..1
    elements "CopyrightYear", :text, :cardinality => 0..n

    # elements "CopyrightOwner", :subset, :cardinality => 0..n
  end
end