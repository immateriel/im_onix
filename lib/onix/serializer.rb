module ONIX
  module Serializer
    class Traverser

      def self.serialize_subset(mod, xml, subset, parent_tag = nil, level = 0)
        if subset.class.included_modules.include?(DateHelper)
          mod.const_get("Date").serialize(xml, subset, parent_tag, level)
        else
          if subset.class.included_modules.include?(CodeHelper)
            mod.const_get("Code").serialize(xml, subset, parent_tag, level)
          else
            if subset.class.included_modules.include?(EntityHelper)
              mod.const_get("Entity").serialize(xml, subset, parent_tag, level)
            else
              mod.const_get("Subset").serialize(xml, parent_tag, subset, level)
            end
          end
        end
      end

      def self.recursive_serialize(mod, xml, subset, parent_tag = nil, level = 0)
        if subset.class.respond_to?(:ancestors_registered_elements)
          subset.class.ancestors_registered_elements.each do |n, e|
            unless e.short
              v = subset.instance_variable_get(e.to_instance)
              if v
                if e.is_array?
                  v.each do |vv|
                    case e.type
                      when :subset
                        self.serialize_subset(mod, xml, vv, n, level)
                      when :text, :integer, :float, :bool
                        mod.const_get("Primitive").serialize(xml, n, vv, level)
                      when :ignore
                      else
                    end
                  end
                else
                  case e.type
                    when :subset
                      self.serialize_subset(mod, xml, v, n, level)
                    when :text, :integer, :float, :bool
                      mod.const_get("Primitive").serialize(xml, n, e.serialize_lambda(v), level)
                    when :ignore
                    else
                  end
                end
              end
            end
          end
        end

      end
    end

    module Default
      class Subset
        def self.serialize(xml, tag, subset, level = 0)
          xml.send(tag, nil) {
            ONIX::Serializer::Traverser.recursive_serialize(Default, xml, subset, tag, level+1)
          }
        end
      end

      class Primitive
        def self.serialize(xml, tag, data, level = 0)
          unless data.respond_to?(:empty?) ? !!data.empty? : !data # rails blank?
            xml.send(tag, data)
          end
        end
      end

      class Date
        def self.serialize(xml, date, parent_tag = nil, level = 0)
          xml.send(parent_tag, nil) {
            ONIX::Serializer::Traverser.recursive_serialize(Default, xml, date, parent_tag, level+1)
            xml.DateFormat(date.date_format.code)
            code_format=date.format_from_code(date.date_format.code)
            xml.Date(date.date.strftime(code_format))
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

      class Entity
        def self.serialize(xml, entity, parent_tag = nil, level = 0)
          xml.send(parent_tag, nil) {
            if entity.role
              Code.serialize(xml, entity.role, entity.class.role_tag, level+1)
            end
            entity.identifiers.each do |identifier|
              Subset.serialize(xml, entity.class.identifier_tag, identifier, level+1)
            end
            if entity.name
              xml.send(entity.class.name_tag, entity.name)
            end
            ONIX::Serializer::Traverser.recursive_serialize(Default, xml, entity, parent_tag, level+1)
          }
        end
      end
    end

    module Dump
      class Subset
        def self.serialize(io, tag, subset, level = 0)
          io.write " "*level
          io.write "#{tag}:\n"
          ONIX::Serializer::Traverser.recursive_serialize(Dump, io, subset, tag, level+1)
        end
      end

      class Primitive
        def self.serialize(io, tag, data, level = 0)
          unless data.respond_to?(:empty?) ? !!data.empty? : !data # rails blank?
            io.write " "*level
            io.write "#{tag} : #{data}\n"
          end
        end
      end

      class Date
        def self.serialize(io, date, parent_tag = nil, level = 0)
          io.write " "*level
          io.write "#{parent_tag}: #{date.date}\n"
        end
      end

      class Code
        def self.serialize(io, code, parent_tag = nil, level = 0)
          io.write " "*level
          io.write "#{parent_tag}: #{code.human}(#{code.code})\n"
        end
      end

      class Entity
        def self.serialize(io, entity, parent_tag = nil, level = 0)
          io.write " "*level
          io.write "#{parent_tag}: #{entity.name}\n"
          if entity.role
            io.write " "*(level+1)
            io.write "Role: #{entity.role.human}(#{entity.role.code})\n"
          end
        end
      end
    end

  end
end