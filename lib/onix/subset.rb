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

  class Subset
    # instanciate Subset form Nokogiri::XML::Element
    def self.parse(n)
      o = self.new
      o.parse(n)
      o
    end

    # parse Nokogiri::XML::Element
    def parse(n) end

    def unsupported(tag)
      #      raise SubsetUnsupported,tag.name
      #      puts "SubsetUnsupported: #{self.class}##{tag.name} (#{ShortToRef.names[tag.name]})"
    end

    def tag_match(v)
      TagNameMatcher.new(v)
    end

    def self.tag_match(v)
      TagNameMatcher.new(v)
    end

  end

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
      if @parse_lambda
        @parse_lambda.call(v)
      else
        v
      end
    end

    def serialize_lambda(v)
      if @serialize_lambda
        @serialize_lambda.call(v)
      else
        v
      end
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
      if @elements[name].shortcut
        current_element = @elements[name]
        define_method current_element.shortcut do |args = nil|
          instance_variable_get(current_element.to_instance)
        end
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
      n.elements.each do |t|
        name = t.name
        e = self.get_registered_element(name)
        if e
          case e.type
          when :subset
            klass = self.get_class(e.class_name)
            val = klass.parse(t) if klass
          when :text
            val = t.text
          when :integer
            val = t.text.to_i
          when :float
            val = t.text.to_f
          when :bool
            val = true
          when :datetime
            tm = t.text
            val = Time.strptime(tm, "%Y%m%dT%H%M%S") rescue Time.strptime(tm, "%Y%m%dT%H%M") rescue Time.strptime(tm, "%Y%m%d") rescue nil
            val ||= tm
          when :ignore
            val = nil
          else
            val = t.text
          end
          if val
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

    def unsupported(tag)
      #      raise SubsetUnsupported,tag.name
      # puts "SubsetUnsupported: #{self.class}##{tag.name} (#{self.class.short_to_ref(tag.name)})"
    end
  end
end