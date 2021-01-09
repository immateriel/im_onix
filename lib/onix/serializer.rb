module ONIX
  class Root < SubsetDSL
    element "ONIXMessage", :subset
    elements "Product", :subset
  end

  module Serializer
    class Traverser

      def self.serialize(mod, xml, subset, tag = nil)
        ONIX::Serializer::Traverser.serialize_subset(mod, xml, subset, tag)
      end

      def self.serialize_subset(mod, data, subset, parent_tag = nil, level = 0)
        if subset.is_a?(ONIX::Root)
          ONIX::Serializer::Traverser.recursive_serialize(mod, data, subset, parent_tag, level)
        else
          if subset.is_a?(ONIX::ONIXMessage)
            mod.const_get("Root").serialize(data, subset, "ONIXMessage", level)
          else
            if subset.class.included_modules.include?(DateHelper)
              mod.const_get("Date").serialize(data, subset, parent_tag, level)
            else
              if subset.class.included_modules.include?(CodeHelper)
                mod.const_get("Code").serialize(data, subset, parent_tag, level)
              else
                mod.const_get("Subset").serialize(data, subset, parent_tag, level)
              end
            end
          end
        end
      end

      def self.any_serialize(type, mod, data, val, tag, level)
        case type
        when :subset
          self.serialize_subset(mod, data, val, tag, level)
        when :datestamp
          mod.const_get("Primitive").serialize(data, val.code, tag, level)
        when :text, :integer, :float
          mod.const_get("Primitive").serialize(data, val, tag, level)
        when :bool
          mod.const_get("Primitive").serialize(data, nil, tag, level) if val
        when :ignore
        else
        end
      end

      def self.recursive_serialize(mod, data, subset, parent_tag = nil, level = 0)
        if subset.class.respond_to?(:ancestors_registered_elements)
          subset.class.ancestors_registered_elements.each do |tag, element|
            next if element.short
            val = subset.instance_variable_get(element.to_instance)
            if val
              if element.is_array?
                val.each do |subval|
                  self.any_serialize(element.type, mod, data, subval, tag, level)
                end
              else
                self.any_serialize(element.type, mod, data, element.serialize_lambda(val), tag, level)
              end
            end
          end
        end
      end
    end

    module Default
      def self.serialize(xml, subset, tag = nil)
        ONIX::Serializer::Traverser.serialize(Default, xml, subset, tag)
      end

      class Root
        def self.serialize(xml, subset, tag, level = 0)
          root_options = subset.version && subset.version >= 300 ? { :xmlns => "http://ns.editeur.org/onix/3.0/reference", :release => subset.release } : {}
          xml.send(tag, root_options) {
            ONIX::Serializer::Traverser.recursive_serialize(Default, xml, subset, tag, level + 1)
          }
        end
      end

      class Subset
        def self.serialize(xml, subset, tag, level = 0)
          if tag
            xml.send(tag, subset.serialized_attributes) {
              ONIX::Serializer::Traverser.recursive_serialize(Default, xml, subset, tag, level + 1)
            }
          end
        end
      end

      class Primitive
        def self.serialize(xml, val, tag, level = 0)
          if val.is_a?(ONIX::TextWithAttributes)
            if val.serialized_attributes["textformat"] == "05" # content is XHTML
              xml.send(tag, val.serialized_attributes) do
                xml.__send__ :insert, val.to_s
              end
            else
              xml.send(tag, val.serialized_attributes, val)
            end
          else
            xml.send(tag, val)
          end
        end
      end

      class Date
        def self.serialize(xml, date, parent_tag = nil, level = 0)
          deprecated_date_format = date.deprecated_date_format
          date_format = date.date_format || DateFormat.from_code("00")
          code_format = date.format_from_code(date_format.code)

          xml.send(parent_tag, nil) {
            date.class.ancestors_registered_elements.each do |tag, element|
              next if element.short
              val = date.instance_variable_get(element.to_instance)
              if val
                case tag
                when "DateFormat"
                  if deprecated_date_format
                    xml.DateFormat(date_format.code)
                  end
                when "Date"
                  if deprecated_date_format
                    xml.Date(date.date.strftime(code_format))
                  else
                    attrs = date.date_format ? { :dateformat => date_format.code } : {}
                    xml.Date(date.date.strftime(code_format), attrs)
                  end
                else
                  ONIX::Serializer::Traverser.any_serialize(element.type, Default, xml, element.serialize_lambda(val), tag, level)
                end
              end
            end
          }
        end
      end

      class Code
        def self.serialize(xml, code, parent_tag = nil, level = 0)
          xml.send(parent_tag, code.serialized_attributes) {
            xml.text(code.code)
          }
        end
      end
    end

    module Dump
      def self.serialize(io, subset, tag = nil)
        ONIX::Serializer::Traverser.serialize(Dump, io, subset, tag)
      end

      class Root
        def self.serialize(io, subset, tag, level = 0)
          io.write " " * level
          io.write "#{tag}(ROOT):\n"
          ONIX::Serializer::Traverser.recursive_serialize(Dump, io, subset, tag, level + 1)
        end
      end

      class Subset
        def self.serialize(io, subset, tag, level = 0)
          io.write " " * level
          if subset.attributes.length > 0
            io.write "#{tag}[#{subset.attributes.to_a.map { |k, v| "#{k}: #{v.code}(#{v.human})" }.join(", ")}]\n"
          else
            io.write "#{tag}:\n"
          end
          ONIX::Serializer::Traverser.recursive_serialize(Dump, io, subset, tag, level + 1)
        end
      end

      class Primitive
        def self.serialize(io, val, tag, level = 0)
          io.write " " * level
          if val.is_a?(ONIX::TextWithAttributes)
            io.write "#{tag}[#{val.attributes.to_a.map { |k, v| "#{k}: #{v.code}(#{v.human})" }.join(", ")}]: #{val.to_s}\n"
          else
            io.write "#{tag}: #{val}\n"
          end
        end
      end

      class Date
        def self.serialize(io, date, parent_tag = nil, level = 0)
          io.write " " * level
          io.write "#{parent_tag}: #{date.date}\n"
        end
      end

      class Code
        def self.serialize(io, code, parent_tag = nil, level = 0)
          io.write " " * level
          io.write "#{parent_tag}: #{code.human}(#{code.code})\n"
        end
      end
    end
  end
end
