require 'onix/serializer'

module ONIX
  class BuilderInvalidArgument < StandardError
  end

  class BuilderInvalidCardinality < StandardError
  end

  class BuilderInvalidCode < StandardError
  end

  class BuilderInvalidChildElement < StandardError
  end

  class BuilderUndefinedElement < StandardError
  end

  class Builder
    def initialize(options = {}, root = nil, &block)
      if root
        @doc = root
        @parent = root
      else
        @parent = @doc = Root.new
      end

      @context = nil
      @arity = nil

      return unless block_given?

      @arity = block.arity
      if @arity <= 0
        @context = eval("self", block.binding)
        instance_eval(&block)
      else
        yield self
      end

      @parent = @doc
    end

    def serialize(xml)
      ONIX::Serializer::Default.serialize(xml, @doc, "Root")
    end

    def dump(io = STDOUT)
      ONIX::Serializer::Dump.serialize(io, @doc, "Root")
    end

    def to_xml
      Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        serialize(xml)
      end.to_xml
    end

    def method_missing(method, *args, &block)
      # :nodoc:
      if @context && @context.respond_to?(method)
        @context.send(method, *args, &block)
      else
        if @parent
          parser_el = @parent.class.ancestors_registered_elements[method.to_s]
          if parser_el
            if ONIX.const_defined?(parser_el.klass_name)
              node = get_class(parser_el.klass_name, args)
            end

            if parser_el.is_array?
              arr = @parent.send(parser_el.underscore_name)
              case parser_el.type
              when :subset
                arr << node
              else
                if args.length > 1
                  txt = TextWithAttributes.new(args[0])
                  txt.parse(args[1])
                  arr << txt
                else
                  arr << args[0]
                end
              end
            else
              case parser_el.type
              when :subset
                @parent.send(parser_el.underscore_name + "=", node)
              when :datestamp
                @parent.send(parser_el.underscore_name + "=", DateStamp.new(args[0], args[1] || "%Y%m%d"))
              else
                if args.length > 1
                  txt = TextWithAttributes.new(args[0])
                  txt.parse(args[1])
                  @parent.send(parser_el.underscore_name + "=", txt)
                else
                  @parent.send(parser_el.underscore_name + "=", args[0])
                end
              end
            end
          else
            raise BuilderInvalidChildElement, [@parent.class.to_s.sub("ONIX::", ""), method.to_s]
          end
        else
          node = get_class(method, args)
        end

        insert(node, &block)
      end
    end

    private

    def get_class(nm, args)
      el = nil
      if ONIX.const_defined?(nm)
        klass = ONIX.const_get(nm)
        if klass.respond_to?(:from_code)
          if args[0].is_a?(String)
            el = klass.from_code(args[0])
            unless el.human
              raise BuilderInvalidCode, [nm.to_s, args[0]]
            end
          else
            if args[0].is_a?(Symbol)
              el = klass.from_human(args[0].to_s)
            else
              raise BuilderInvalidArgument, [nm.to_s, args[0]]
            end
          end
        else
          el = klass.new
          if el.is_a?(ONIX::ONIXMessage)
            el.release = args[0]
          end
        end
      else
        raise BuilderUndefinedElement, nm
      end
      el
    end

    def insert(node, &block)
      if block_given?
        old_parent = @parent
        @parent = node
        @arity ||= block.arity
        if @arity <= 0
          instance_eval(&block)
        else
          block.call(self)
        end
        @parent = old_parent
      end
    end
  end
end
