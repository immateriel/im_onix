module ONIX
  module Serializer
    class Default
      class Subset
        def self.serialize(xml, tag, subset)
          xml.send(tag, nil) {
            self.recursive_serialize(xml, subset)
          }
        end
        def self.recursive_serialize(xml, subset)
          if subset.class.respond_to?(:ancestors_registered_elements)
            subset.class.ancestors_registered_elements.each do |n, e|
              unless e.short
                v = subset.instance_variable_get(e.to_instance)
                if v
                  if e.is_array?
                    v.each do |vv|
                      case e.type
                        when :subset
                          self.serialize(xml,n,vv)
                        when :text, :integer, :float, :bool
                          Primitive.serialize(xml, n, vv)
                        when :ignore
                        else
                      end
                    end
                  else
                    case e.type
                      when :subset
                        self.serialize(xml,n,v)
                      when :text, :integer, :float, :bool
                        Primitive.serialize(xml, n, e.serialize_lambda(v))
                      when :ignore
                      else
                    end
                  end
                end
              end
            end
          end
          if subset.class.included_modules.include?(DateHelper)
            Date.serialize(xml, subset)
          end
          if subset.class.included_modules.include?(CodeHelper)
            Code.serialize(xml, subset)
          end
          if subset.class.included_modules.include?(EntityHelper)
            Entity.serialize(xml, subset)
          end
        end
      end

      class Primitive
        def self.serialize(xml, tag, data)
          unless data.respond_to?(:empty?) ? !!data.empty? : !data # rails blank?
            xml.send(tag, data)
          end
        end
      end

      class Date
        def self.serialize(xml, date)
          xml.DateFormat(date.date_format.code)
          code_format=date.format_from_code(date.date_format.code)
          xml.Date(date.date.strftime(code_format))
        end
      end

      class Code
        def self.serialize(xml, code)
          xml.text(code.code)
        end
      end

      class Entity
        def self.serialize(xml, entity)
          if entity.role
            xml.send(entity.class.role_tag,nil) {
              Subset.recursive_serialize(xml, entity.role)
            }
          end
          entity.identifiers.each do |identifier|
            xml.send(entity.class.identifier_tag,nil){
              Subset.recursive_serialize(xml, identifier)
            }
          end
          if entity.name
            xml.send(entity.class.name_tag,entity.name)
          end
        end
      end
    end
  end
end