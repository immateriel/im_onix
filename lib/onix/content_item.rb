require 'onix/text_item'
require 'onix/contributor'
require 'onix/language'
require 'onix/subject'
require 'onix/title_detail'
require 'onix/text_content'
require 'onix/cited_content'
require 'onix/supporting_resource'
require 'onix/related_work'
require 'onix/related_product'

module ONIX
  class ContentItem < SubsetDSL
    element "LevelSequenceNumber", :integer, :cardinality => 0..1
    element "TextItem", :subset, :cardinality => 0..1
    # element "AVItem", :subset, :cardinality => 0..1
    element "ComponentTypeName", :text, :cardinality => 0..1
    element "ComponentNumber", :text, :cardinality => 0..1
    elements "TitleDetail", :subset, :cardinality => 0..n
    elements "Contributor", :subset, :cardinality => 0..n
    elements "ContributorStatement", :text, :cardinality => 0..n
    element "NoContributor", :bool, :cardinality => 0..1
    elements "Language", :subset, :cardinality => 0..n
    elements "Subject", :subset, :cardinality => 0..n
    # elements "NameAsSubject", :subset, :cardinality => 0..n
    elements "TextContent", :subset, :cardinality => 0..n
    elements "CitedContent", :subset, :cardinality => 0..n
    elements "SupportingResource", :subset, :cardinality => 0..n
    elements "RelatedWork", :subset, :cardinality => 0..n
    elements "RelatedProduct", :subset, :cardinality => 0..n
  end
end