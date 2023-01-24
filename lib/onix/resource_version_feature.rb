module ONIX
  class ResourceVersionFeature < SubsetDSL
    element "ResourceVersionFeatureType", :subset, :shortcut => :type, :cardinality => 1
    elements "FeatureNote", :text, :shortcut => :notes, :cardinality => 0..n
    element "FeatureValue", :text, {
      :shortcut => :value,
      :serialize_lambda => lambda { |v| v.class == SupportingResourceFileFormat ? v.code : v }
    }

    scope :image_pixels_width, lambda { human_code_match(:resource_version_feature_type, "ImageWidthInPixels") }
    scope :image_pixels_height, lambda { human_code_match(:resource_version_feature_type, "ImageHeightInPixels") }
    scope :md5_hash, lambda { human_code_match(:resource_version_feature_type, "Md5HashValue") }

    def parse(n)
      super

      if @resource_version_feature_type.human == "FileFormat"
        @feature_value = SupportingResourceFileFormat.from_code(@feature_value)
      end
    end
  end
end