require 'onix/date'
require 'onix/resource_version'
require 'onix/resource_feature'

module ONIX
  class SupportingResource < SubsetDSL
    element "ResourceContentType", :subset, :shortcut => :type, :cardinality => 1
    element "ContentAudience", :subset, :shortcut => :target_audience, :cardinality => 1..n
    element "Territory", :subset, :cardinality => 0..1
    element "ResourceMode", :subset, :shortcut => :mode, :cardinality => 1
    elements "ResourceFeature", :subset, :shortcut => :features, :cardinality => 0..n
    elements "ResourceVersion", :subset, :shortcut => :versions, :cardinality => 1..n

    scope :front_cover, lambda { human_code_match(:resource_content_type, "FrontCover") }
    scope :sample_content, lambda { human_code_match(:resource_content_type, "SampleContent") }

    scope :image, lambda { human_code_match(:resource_mode, "Image") }
    scope :text, lambda { human_code_match(:resource_mode, "Text") }

    def caption_feature
      self.features.caption.first
    end

    def caption
      if self.caption_feature
        self.caption_feature.value
      end
    end
  end
end
