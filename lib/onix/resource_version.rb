require 'onix/resource_version_feature'

module ONIX
  class ResourceVersion < SubsetDSL
    element "ResourceForm", :subset, :shortcut => :form, :cardinality => 1
    elements "ResourceVersionFeature", :subset, :shortcut => :features, :cardinality => 0..n
    elements "ResourceLink", :text, :shortcut => :links, :cardinality => 1..n
    elements "ContentDate", :subset, :cardinality => 0..n

    # @return [String]
    def filename
      if @resource_form.human == "DownloadableFile"
        resource_links.first
      end
    end

    # @return [ResourceVersionFeature]
    def file_format_feature
      @resource_version_features.select { |f| f.type.human == "FileFormat" }.first
    end

    # @return [String]
    def file_format
      if ["DownloadableFile", "LinkableResource"].include?(@resource_form.human)
        if file_format_feature
          file_format_feature.value.human
        end
      end
    end

    def file_mimetype
      if ["DownloadableFile", "LinkableResource"].include?(@resource_form.human)
        if file_format_feature
          file_format_feature.value.mimetype
        end
      end
    end

    def image_width_feature
      @resource_version_features.image_pixels_width.first
    end

    def image_height_feature
      @resource_version_features.image_pixels_height.first
    end

    def md5_hash_feature
      @resource_version_features.md5_hash.first
    end

    def image_width
      if self.image_width_feature
        self.image_width_feature.value.to_i
      end
    end

    def image_height
      if self.image_height_feature
        self.image_height_feature.value.to_i
      end
    end

    def md5_hash
      if self.md5_hash_feature
        self.md5_hash_feature.value
      end
    end

    def last_updated_content_date
      @content_dates.last_updated.first
    end

    def last_updated
      if self.last_updated_content_date
        self.last_updated_content_date.date
      end
    end

    def last_updated_utc
      if self.last_updated_content_date and self.last_updated_content_date.date
        self.last_updated_content_date.date.to_time.utc.strftime('%Y%m%dT%H%M%S%z')
      end
    end
  end
end
