require 'forwardable'
require 'cgi'

module ONIX
  class ShortToRef
    def self.names
      @shortnames ||= YAML.load(File.open(File.dirname(__FILE__) + "/../../data/shortnames.yml"))
    end
  end

  class RefToShort
    def self.names
      @refnames ||= ShortToRef.names.invert
    end
  end

  TagNameMatcher = Struct.new(:tag_name) do
    def ===(target)
      if target.element?
        name = target.name
        name.casecmp(tag_name) == 0 or ShortToRef.names[name] == tag_name
      else
        false
      end
    end
  end

  module Attributes
    # @return [Hash<String,Code>]
    attr_accessor :attributes

    # @return [Hash<String,String>]
    def serialized_attributes
      if @attributes and @attributes.length > 0
        attrs = {}
        @attributes.each do |k, v|
          attrs[k] = v.code if v
        end
        attrs
      end
    end

    # @param [String] attr
    # @return [Class]
    def self.attribute_class(attr)
      case attr
      when "textcase"
        TextCase
      when "textformat"
        TextFormat
      when "language"
        LanguageCode
      when "dateformat"
        DateFormat
      when "datestamp"
        DateStamp
      else
        nil
      end
    end

    def parse_attributes(attrs)
      @attributes ||= {}
      attrs.each do |k, v|
        attr_klass = Attributes.attribute_class(k.to_s)
        @attributes[k.to_s] = attr_klass ? attr_klass.from_code(v.to_s) : nil
      end
    end
  end

  class Subset
    include Attributes

    # instanciate Subset form Nokogiri::XML::Element
    # @param [Nokogiri::XML::Element] n
    def self.parse(n)
      o = self.new
      o.parse(n)
      o
    end

    # parse Nokogiri::XML::Element
    # @param [Nokogiri::XML::Element] n
    def parse(n) end

    def unsupported(tag)
      # raise SubsetUnsupported, [self.class, tag.name]
      # puts "WARN subset tag unsupported #{self.class}##{tag.name} (#{self.class.short_to_ref(tag.name)})"
    end

    def tag_match(v)
      TagNameMatcher.new(v)
    end

    def self.tag_match(v)
      TagNameMatcher.new(v)
    end
  end

  # for class DSL
  class ElementParser
    attr_accessor :type, :name, :short, :cardinality, :klass_name

    def self.inflectors
      [['ox', 'oxes'],
       ['us', 'uses'],
       ['', 's'],
       ['ero', 'eroes'],
       ['rf', 'rves'],
       ['af', 'aves'],
       ['ero', 'eroes'],
       ['man', 'men'],
       ['ch', 'ches'],
       ['sh', 'shes'],
       ['ss', 'sses'],
       ['ta', 'tum'],
       ['ia', 'ium'],
       ['ra', 'rum'],
       ['ay', 'ays'],
       ['ey', 'eys'],
       ['oy', 'oys'],
       ['uy', 'uys'],
       ['y', 'ies'],
       ['x', 'xes'],
       ['lf', 'lves'],
       ['ffe', 'ffes'],
       ['afe', 'aves'],
       ['ouse', 'ouses']]
    end

    def initialize(name, type, options = {})
      @name = name
      @type = type
      @pluralize = true
      @short = false
      @array = false
      @parse_lambda = nil
      @serialize_lambda = nil
      if options[:array]
        @array = true
      end
      if options[:pluralize] == false
        @pluralize = false
      end

      @parse_lambda = options[:parse_lambda]
      @serialize_lambda = options[:serialize_lambda]
      @shortcut = options[:shortcut]
      @cardinality = options[:cardinality]
      @cardinality = nil if @cardinality == 0..n # no need to check if 0..n

      if options[:klass]
        @klass_name = options[:klass]
      else
        @klass_name = name
      end
    end

    def shortcut
      @shortcut
    end

    def parse_lambda(v)
      @parse_lambda ? @parse_lambda.call(v) : v
    end

    def serialize_lambda(v)
      @serialize_lambda ? @serialize_lambda.call(v) : v
    end

    def is_array?
      @array
    end

    def _underscore_name
      if @array and @pluralize
        pluralize(underscore(@name))
      else
        underscore(@name)
      end
    end

    def underscore_name
      @underscore_name ||= _underscore_name
    end

    def class_name
      @klass_name
    end

    def to_sym
      @sym ||= self.underscore_name.to_sym
    end

    def to_instance
      @instance ||= "@" + self.underscore_name
    end

    private

    def pluralize(str)
      rex = /(#{self.class.inflectors.map { |si, pl| si }.join('|')})$/i
      hash = Hash[*self.class.inflectors.flatten]
      str.sub(rex) { |m| hash[m] }
    end

    def underscore(str)
      word = str.to_s.dup
      word.gsub!('::', '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end

  class SubsetArray < Array
    def human_code_match(k, p)
      case p
      when Regexp
        self.class.new(self.select { |v|
          code = v.instance_variable_get("@" + k.to_s)
          code and code.human =~ p
        })
      when Array
        self.class.new(self.select { |v|
          code = v.instance_variable_get("@" + k.to_s)
          code and p.include?(code.human)
        })
      else
        self.class.new(self.select { |v|
          code = v.instance_variable_get("@" + k.to_s)
          code and code.human == p
        })
      end
    end

    def code_match(k, p)
      case p
      when Regexp
        self.class.new(self.select { |v|
          code = v.instance_variable_get("@" + k.to_s)
          code.code =~ p
        })
      else
        self.class.new(self.select { |v| v.instance_variable_get("@" + k.to_s).code == p })
      end
    end
  end

  class TextWithAttributes < SimpleDelegator
    include Attributes

    def parse(attrs)
      parse_attributes(attrs)
    end
  end

  # DSL
  class SubsetDSL < Subset
    def self.scope(name, lambda)
      @scopes ||= {}
      @scopes[name] = lambda
    end

    def self._ancestor_registered_scopes
      els = self.registered_scopes
      sup = self
      while sup.respond_to?(:registered_scopes)
        els.merge!(sup.registered_scopes) if sup.registered_scopes
        sup = sup.superclass
      end
      els
    end

    def self.ancestor_registered_scopes
      @ancestors_registered_scopes ||= _ancestor_registered_scopes
    end

    def self.registered_scopes
      @scopes || {}
    end

    def self.element(name, type, options = {})
      @elements ||= {}
      @elements[name] = ElementParser.new(name, type, options)
      short_name = self.ref_to_short(name)
      if short_name
        @elements[short_name] = @elements[name].dup
        @elements[short_name].short = true
      end

      attr_accessor @elements[name].to_sym

      alias_method "#{@elements[name].underscore_name}_with_attributes".to_sym, @elements[name].to_sym

      current_element = @elements[name]
      define_method current_element.to_sym do |args = nil|
        val = instance_variable_get(current_element.to_instance)
        if val.respond_to?(:__getobj__)
          val.__getobj__
        else
          if val.is_a?(SubsetArray) and val.first and val.first.is_a?(TextWithAttributes)
            val.map{|v| v.respond_to?(:__getobj__) ? v.__getobj__ : v}
          else
            val
          end
        end
      end

      if @elements[name].shortcut
        current_element = @elements[name]
        alias_method "#{current_element.shortcut.to_s}_with_attributes".to_sym, "#{@elements[name].underscore_name}_with_attributes".to_sym
        alias_method current_element.shortcut, @elements[name].to_sym
      end
    end

    # shortcut for element :array=>true
    def self.elements(name, type, options = {})
      self.element(name, type, options.merge(:array => true))
    end

    def self._ancestors_registered_elements
      els = self.registered_elements
      sup = self
      while sup.respond_to?(:registered_elements)
        els.merge!(sup.registered_elements) if sup.registered_elements
        sup = sup.superclass
      end
      els
    end

    def self.ancestors_registered_elements
      @ancestors_registered_elements ||= _ancestors_registered_elements
    end

    def self.registered_elements
      @elements || {}
    end

    def initialize
      # initialize plural as Array
      self.class.ancestors_registered_elements.each do |k, e|
        if e.is_array?
          # register a contextual SubsetArray object
          subset_array = SubsetArray.new
          subset_klass = self.class.get_class(e.class_name)
          if subset_klass.respond_to? :registered_scopes
            subset_klass.registered_scopes.each do |n, l|
              unless subset_array.respond_to? n.to_s
                subset_array.define_singleton_method(n.to_s) do
                  instance_exec(&l)
                end
              end
            end
          end
          instance_variable_set(e.to_instance, subset_array)
        end
      end
    end

    def self.short_to_ref(name)
      ShortToRef.names[name]
    end

    def self.ref_to_short(name)
      RefToShort.names[name]
    end

    def self.get_class(name)
      ONIX.const_get(name) if ONIX.const_defined? name
    end

    # infinity constant for cardinality
    def self.n
      Float::INFINITY
    end

    def get_registered_element(name)
      self.class.ancestors_registered_elements[name]
    end

    def get_class(name)
      self.class.get_class(name)
    end

    def parse(n)
      parse_attributes(n.attributes)
      n.elements.each do |t|
        name = t.name
        e = self.get_registered_element(name)
        if e
          primitive = true
          case e.type
          when :subset
            klass = self.get_class(e.class_name)
            unless klass
              raise UnknownElement, e.class_name
            end
            val = klass.parse(t)
            primitive = false
          when :text
            val = t.text
          when :integer
            val = t.text.to_i
          when :float
            val = t.text.to_f
          when :bool
            val = true
          when :date
            fmt = t["dateformat"] || "00"
            begin
              val = ONIX::Helper.to_date(fmt, t.text)
            rescue
              val = t.text
            end
          when :datestamp
            tm = t.text
            datestamp = DateStamp.new
            datestamp.parse(tm)
            val = datestamp
          when :ignore
            val = nil
          else
            val = t.text
          end

          if val
            if primitive && t.attributes.length > 0
              if t.attributes["textformat"] && t.attributes["textformat"].to_s == "05" # content is XHTML
                val = CGI.unescapeHTML(t.children.map { |x| x.to_s }.join.strip)
              end
              val = TextWithAttributes.new(val)
              val.parse(t.attributes)
            end

            if e.is_array?
              instance_variable_get(e.to_instance).send(:push, val)
            else
              instance_variable_set(e.to_instance, e.parse_lambda(val))
            end
          end

        else
          unsupported(t)
        end
      end
    end
  end
end