require 'forwardable'
require 'cgi'
require 'delegate'

module ONIX
  class ShortToRef
    def self.names
      @shortnames ||= YAML.load(File.open(File.dirname(__FILE__) + "/../../data/shortnames.yml")).freeze
    end
  end

  class RefToShort
    def self.names
      @refnames ||= ShortToRef.names.invert.freeze
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

  # String only code-like class
  class TextAttr
    attr_accessor :code, :human

    def self.from_code(code)
      obj = self.new
      obj.code = code
      obj.human = code
      obj
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
      when "sourcename"
        TextAttr
      when "sourcetype"
        RecordSourceType
      when "collationkey"
        TextAttr
      when "dateformat"
        DateFormat
      when "datestamp"
        DateStamp
      when "language"
        LanguageCode
      when "textcase"
        TextCase
      when "textformat"
        TextFormat
      when "textscript"
        ScriptCode
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
    # @return [Subset]
    def self.parse(n)
      o = self.new
      o.parse(n)
      o
    end

    # parse Nokogiri::XML::Element
    # @param [Nokogiri::XML::Element] n
    # @return [void]
    def parse(n) end

    # called when tag is not defined
    # @param [String] tag
    def unsupported(tag)
      # raise SubsetUnsupported, [self.class, tag.name]
      # puts "WARN subset tag unsupported #{self.class}##{tag.name} (#{self.class.short_to_ref(tag.name)})"
    end

    def tag_match(v)
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

    # @return [String]
    def underscore_name
      @underscore_name ||= (@array && @pluralize) ? pluralize(underscore(@name)) : underscore(@name)
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
    # @param [Symbol] k
    # @param [String] p
    # @return [SubsetArray]
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

    # @param [Symbol] k
    # @param [String] p
    # @return [SubsetArray]
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
    class << self
      # convert short name notation to reference
      # @param [String] name
      # @return [String]
      def short_to_ref(name)
        ShortToRef.names[name]
      end

      # convert reference name notation to short
      # @param [String] name
      # @return [String]
      def ref_to_short(name)
        RefToShort.names[name]
      end

      # infinity constant for cardinality
      def n
        Float::INFINITY
      end

      # define a scope
      # @param [Symbol] name
      # @param [Lambda] lambda
      # @return [void]
      def scope(name, lambda)
        @scopes ||= {}
        @scopes[name] = lambda
      end

      def registered_scopes
        @scopes || {}
      end

      def register_scopes(scopes)
        @scopes ||= {}
        @scopes = scopes.merge(@scopes)
      end

      # define unique element
      # @param [String] name
      # @param [Symbol] type
      # @param [Hash] options
      # @return [void]
      def element(name, type, options = {})
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
              val.map { |v| v.respond_to?(:__getobj__) ? v.__getobj__ : v }
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

        @elements[name]
      end

      # define multiple elements
      # shortcut for element :array=>true
      # @param [String] name
      # @param [Symbol] type
      # @param [Hash] options
      # @return [void]
      def elements(name, type, options = {})
        self.element(name, type, options.merge(:array => true))
      end

      # registered elements for this subset
      # @return [Hash]
      def registered_elements
        @elements || {}
      end

      def register_elements(elements)
        @elements ||= {}
        @elements.merge!(elements)
      end

      def get_class(name)
        ONIX.const_get(name) if ONIX.const_defined?(name)
      end

      def inherited(sublass)
        sublass.register_scopes(self.registered_scopes)
        sublass.register_elements(self.registered_elements)
      end
    end

    def initialize
      # initialize plural as Array
      self.registered_elements.values.each do |e|
        if e.is_array?
          register_subset_array(e)
        end
      end
    end

    def register_subset_array(e)
      # register a contextual SubsetArray object
      subset_array = SubsetArray.new
      subset_klass = self.get_class(e.class_name)
      if subset_klass.respond_to?(:registered_scopes)
        subset_klass.registered_scopes.each do |n, l|
          unless subset_array.respond_to?(n.to_s)
            subset_array.define_singleton_method(n.to_s) do
              instance_exec(&l)
            end
          end
        end
      end
      instance_variable_set(e.to_instance, subset_array)
    end

    def registered_elements
      self.class.registered_elements
    end

    def get_class(name)
      self.class.get_class(name)
    end

    # @param [Nokogiri::XML::Element] n
    # @return [void]
    def parse(n)
      parse_attributes(n.attributes)
      n.elements.each do |t|
        e = self.registered_elements[t.name]
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
                xhtml = CGI.unescapeHTML(t.children.map { |x| x.to_s }.join.strip)
                if Nokogiri::XML.parse(xhtml).root # check if val is really XHTML
                  val = xhtml
                else
                  xhtml = CGI.unescapeHTML(val)
                  if Nokogiri::XML.parse(xhtml).root
                    val = xhtml
                  end
                end
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
