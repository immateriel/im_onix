module ONIX
  class PublisherRepresentative < SubsetDSL
    element "AgentRole", :subset, :cardinality => 1
    elements "AgentIdentifier", :subset, :cardinality => 0..n
    element "AgentName", :text, :cardinality => 0..1
    elements "TelephoneNumber", :text, :cardinality => 0..n
    elements "FaxNumber", :text, :cardinality => 0..n
    elements "EmailAddress", :text, :cardinality => 0..n
    elements "Website", :subset, :cardinality => 0..n
  end
end
