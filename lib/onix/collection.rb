require 'onix/collection_sequence'

module ONIX
  class Collection < SubsetDSL
    element "CollectionType", :subset, :shortcut => :type, :cardinality => 1
    element "SourceName", :text, :cardinality => 0..1
    elements "CollectionIdentifier", :subset, :shortcut => :identifiers, :cardinality => 0..n
    elements "CollectionSequence", :subset, :shortcut => :sequences, :cardinality => 0..n
    elements "TitleDetail", :subset, :cardinality => 0..n
    elements "Contributor", :subset, :cardinality => 0..n
    elements "ContributorStatement", :text, :cardinality => 0..n
    elements "ContributorStatement", :text, :cardinality => 0..n
    element "NoContributor", :bool, :cardinality => 0..1

    scope :publisher, lambda { human_code_match(:collection_type, "PublisherCollection") }

    # @!group High level

    # collection title string
    # @return [String]
    def title
      if collection_title_element
        collection_title_element.title
      end
    end

    # collection subtitle string
    # @return [String]
    def subtitle
      if collection_title_element
        collection_title_element.subtitle
      end
    end

    # @return [TitleElement]
    def collection_title_element
      distinctive_title = @title_details.distinctive_title.first
      #select { |td| td.type.human=~/DistinctiveTitle/}.first
      if distinctive_title
        distinctive_title.title_elements.collection_level.first
        #select { |te| te.level.human=~/CollectionLevel/ or te.level.human=~/Subcollection/ }.first
      end
    end

    # @!endgroup

  end
end