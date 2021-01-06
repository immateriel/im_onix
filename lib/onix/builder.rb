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

  class Fragment < SubsetDSL
    elements "Product", :subset
  end

  # ONIX builder DSL with human code resolve, code validity and child element validity, elements cardinality check
  class Builder
    attr_accessor :parent, :name, :element, :children, :context

    def initialize(parent = nil)
      @children = []
      @parent = parent
    end

    def method_missing(m, *args, &block)
      if @context && @context.respond_to?(m)
        @context.send(m, *args, &block)
      else
        @children << make_element(m, args, &block)
      end
    end

    def fragment &block
      make_element(nil, nil, &block)
    end

    # Nokogiri::XML::Builder or DocumentFragment
    def xml
      if @element.is_a?(Fragment)
        frag = Nokogiri::XML::DocumentFragment.parse("")
        Nokogiri::XML::Builder.with( frag ) do |xml|
          ONIX::Serializer::Default.serialize(xml, @element, @name)
        end
        frag
      else
        builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
          ONIX::Serializer::Default.serialize(xml, @element, @name)
        end
        builder
      end
    end

    def dump(io = STDOUT)
      ONIX::Serializer::Dump.serialize(io, @element, @name)
    end

    def check_cardinality!
      if @parent
        children_h = {}
        @children.compact.each do |tag|
          children_h[tag] ||= 0
          children_h[tag] += 1
        end
        @parent.class.ancestors_registered_elements.each do |k, v|
          children_h[k] ||= 0 if k.downcase != k
          if children_h[k]
            cardinality = v.cardinality
            if cardinality
              if cardinality.is_a?(Range)
                unless cardinality.cover?(children_h[k])
                  raise BuilderInvalidCardinality, [@name.to_s, k, children_h[k], cardinality]
                end
              else
                unless children_h[k] == cardinality
                  raise BuilderInvalidCardinality, [@name.to_s, k, children_h[k], cardinality]
                end
              end
            end
          end
        end
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

    def set_data(el, args)

    end

    def insert_element(el, &block)
      builder = Builder.new(el)
      builder.context = @context

      if @context
        @context.instance_variables.each do |k|
          v = @context.instance_variable_get(k)
          builder.instance_variable_set(k, v)
        end
      end

      if block.arity == 1
        block.call builder
      else
        builder.instance_eval(&block)
      end
      builder.check_cardinality!
      builder
    end

    def make_element(nm, args, &block)
      @name = nm.to_s

      if @parent
        parser_el = @parent.class.ancestors_registered_elements[@name]
        if parser_el
          if ONIX.const_defined?(parser_el.klass_name)
            el = get_class(parser_el.klass_name, args)
          end

          if parser_el.is_array?
            arr = @parent.send(parser_el.underscore_name)
            case parser_el.type
            when :subset
              arr << el
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
              @parent.send(parser_el.underscore_name + "=", el)
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
          raise BuilderInvalidChildElement, [@parent.class.to_s.sub("ONIX::", ""), nm.to_s]
        end
      else
        if nm
          el = get_class(nm, args)
        else
          el = Fragment.new
        end
      end

      if block_given?
        @context = nil unless eval("self", block.binding).is_a?(ONIX::Builder)
        @context ||= eval("self", block.binding)
        insert_element(el, &block)
      end

      @element = el
      @name
    end
  end
end