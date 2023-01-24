module ONIX
  class EpubLicenseExpression < SubsetDSL
    element "EpubLicenseExpressionType", :subset, :cardinality => 1
    element "EpubLicenseExpressionTypeName", :text, :cardinality => 0..1
    element "EpubLicenseExpressionLink", :text, :cardinality => 1
  end
end