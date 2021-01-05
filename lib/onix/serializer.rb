module ONIX
  module Serializer
    class Traverser

      def self.serialize(mod, xml, subset, tag = nil)
        ONIX::Serializer::Traverser.serialize_subset(mod, xml, subset, tag)
      end

      def self.serialize_subset(mod, data, subset, parent_tag = nil, level = 0)
        if subset.is_a?(ONIX::ONIXMessage)
          mod.const_get("Root").serialize(data, "ONIXMessage", subset, level)
        else
          if subset.class.included_modules.include?(DateHelper)
            mod.const_get("Date").serialize(data, subset, parent_tag, level)
          else
            if subset.class.included_modules.include?(CodeHelper)
              mod.const_get("Code").serialize(data, subset, parent_tag, level)
            else
              mod.const_get("Subset").serialize(data, parent_tag, subset, level)
            end
          end
        end
      end

      def self.subset_serialize(type, mod, data, vv, n, level)
        case type
        when :subset
          self.serialize_subset(mod, data, vv, n, level)
        when :text, :integer, :float, :datetime
          mod.const_get("Primitive").serialize(data, n, vv, level)
        when :bool
          mod.const_get("Primitive").serialize(data, n, nil, level) if vv
        when :ignore
        else
        end
      end

      def self.recursive_serialize(mod, data, subset, parent_tag = nil, level = 0)
        if subset.class.respond_to?(:ancestors_registered_elements)
          subset.class.ancestors_registered_elements.each do |n, e|
            unless e.short
              v = subset.instance_variable_get(e.to_instance)
              if v
                if e.is_array?
                  v.each do |vv|
                    self.subset_serialize(e.type, mod, data, vv, n, level)
                  end
                else
                  vv = e.serialize_lambda(v)
                  self.subset_serialize(e.type, mod, data, vv, n, level)
                end
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
        def self.serialize(xml, tag, subset, level = 0)
          root_options = subset.version && subset.version >= 300 ? { :xmlns => "http://www.editeur.org/onix/3.0/reference", :release => subset.release } : {}
          xml.send(tag, root_options) {
            ONIX::Serializer::Traverser.recursive_serialize(Default, xml, subset, tag, level + 1)
          }
        end
      end

      class Subset
        def self.serialize(xml, tag, subset, level = 0)
          xml.send(tag, nil) {
            ONIX::Serializer::Traverser.recursive_serialize(Default, xml, subset, tag, level + 1)
          }
        end
      end

      class Primitive
        def self.serialize(xml, tag, val, level = 0)
          if val.is_a?(ONIX::TextWithAttributes)
            attrs = {}
            val.attributes.each do |k, v|
              attrs[k] = v.code
            end

            if val.attributes["textformat"] && ["Html", "Xml", "Xhtml"].include?(val.attributes["textformat"].human)
              xml.send(tag, attrs) do
                xml.__send__ :insert, Nokogiri::XML::DocumentFragment.parse(val)
              end
            else
              xml.send(tag, val, attrs)
            end
          else
            xml.send(tag, val)
          end
        end
      end

      class Date
        def self.serialize(xml, date, parent_tag = nil, level = 0)
          xml.send(parent_tag, nil) {
            ONIX::Serializer::Traverser.recursive_serialize(Default, xml, date, parent_tag, level + 1)
            #xml.DateFormat(date.date_format.code)
            code_format = date.format_from_code(date.date_format.code)
            xml.Date(date.date.strftime(code_format), :dateformat => date.date_format.code)
          }
        end
      end

      class Code
        def self.serialize(xml, code, parent_tag = nil, level = 0)
          xml.send(parent_tag, nil) {
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
        def self.serialize(io, tag, subset, level = 0)
          io.write " " * level
          io.write "#{tag}(ROOT):\n"
          ONIX::Serializer::Traverser.recursive_serialize(Dump, io, subset, tag, level + 1)
        end
      end

      class Subset
        def self.serialize(io, tag, subset, level = 0)
          io.write " " * level
          io.write "#{tag}:\n"
          ONIX::Serializer::Traverser.recursive_serialize(Dump, io, subset, tag, level + 1)
        end
      end

      class Primitive
        def self.serialize(io, tag, val, level = 0)
          io.write " " * level
          io.write "#{tag}: #{val}\n"
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
