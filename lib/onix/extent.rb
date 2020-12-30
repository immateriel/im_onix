module ONIX
  class Extent < SubsetDSL
    element "ExtentType", :subset, :shortcut => :type
    element "ExtentValue", :text, :shortcut => :value
    element "ExtentUnit", :subset, :shortcut => :unit

    scope :filesize, lambda { human_code_match(:extent_type, /Filesize/) }
    scope :page, lambda { human_code_match(:extent_type, /Page/) }

    # @!group High level

    # bytes count
    # @return [Integer]
    def bytes
      case @extent_unit.human
      when "Bytes"
        @extent_value.to_i
      when "Kbytes"
        (@extent_value.to_f * 1024).to_i
      when "Mbytes"
        (@extent_value.to_f * 1024 * 1024).to_i
      else
        nil
      end
    end

    # pages count
    # @return [Integer]
    def pages
      if @extent_unit.human == "Pages"
        @extent_value.to_i
      else
        nil
      end
    end

    # @!endgroup
  end
end
