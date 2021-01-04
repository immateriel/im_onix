require 'onix/epub_license_expression'

module ONIX
  class EpubLicense < SubsetDSL
    elements "EpubLicenseName", :text, :cardinality => 1..n
    elements "EpubLicenseExpression", :subset, :cardinality => 0..n
  end
end