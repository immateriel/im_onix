module ONIX
  class Short
    def self.names
      @shortnames||=YAML.load(File.open(File.dirname(__FILE__) + "/../../data/shortnames.yml"))
    end
  end

  TagNameMatcher = Struct.new(:tag_name) do
    def ===(target)
      if target.element?
        name=target.name
        name.casecmp(tag_name) == 0 or Short.names[name] == tag_name
      else
        false
      end
    end
  end

  class Subset
    # instanciate Subset form Nokogiri::XML::Element
    def self.parse(n)
      o=self.new
      o.parse(n)
      o
    end

    # parse Nokogiri::XML::Element
    def parse(n)
    end

    def unsupported(tag)
#      raise SubsetUnsupported,tag.name
#      puts "SubsetUnsupported: #{self.class}##{tag.name} (#{Short.names[tag.name]})"
    end

    def tag_match(v)
      TagNameMatcher.new(v)
    end

    def self.tag_match(v)
      TagNameMatcher.new(v)
    end

  end

  class ElementParser
    attr_accessor :type, :name

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

    def initialize(name, type, options={})
      @name=name
      @type=type
      @pluralize=true
      @array=false
      @lambda=nil
      if options[:array]
        @array=true
      end
      if options[:pluralize]==false
        @pluralize=false
      end
      if options[:lambda]
        @lambda=options[:lambda]
      end
      if options[:klass]
        @klass_name=options[:klass]
      else
        @klass_name=name
      end
    end

    def lambda(v)
      if @lambda
        @lambda.call(v)
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
      @underscore_name||=_underscore_name
    end

    def class_name
      @klass_name
    end

    def to_sym
      @sym||=self.underscore_name.to_sym
    end

    def to_instance
      @instance||="@"+self.underscore_name
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

  class SubsetDSL < Subset
    def self.element(name, type, options={})
      @elements ||= {}
      @elements[name]=ElementParser.new(name, type, options)
#      puts "REGISTER ELEMENT #{name} #{@elements[name].to_instance}"
      attr_accessor @elements[name].to_sym
    end

    # shortcut for element :array=>true
    def self.elements(name, type, options={})
      self.element(name,type,options.merge(:array=>true))
    end

    def self._ancestors_registered_elements
      els=self.registered_elements
      sup=self
      while sup.respond_to?(:registered_elements)
        els.merge!(sup.registered_elements) if sup.registered_elements
        sup=sup.superclass
      end
      els
    end

    def self.ancestors_registered_elements
      @ancestors_registered_elements||=_ancestors_registered_elements
    end

    def self.registered_elements
      @elements
    end

    def initialize
      # initialize plural as Array
      self.class.ancestors_registered_elements.each do |k,e|
        if e.is_array?
          instance_variable_set(e.to_instance,[])
        end
      end
    end

    def parse(n)
      n.elements.each do |t|
        name = t.name
        if Short.names[name]
          name=Short.names[name]
        end
        e=self.class.ancestors_registered_elements[name]
        if e
          case e.type
            when :subset
              val=ONIX.const_get(e.class_name).parse(t)
            when :text
              val=t.text
            when :integer
              val=t.text.to_i
            when :float
              val=t.text.to_f
            when :bool
              val=true
            else
              val=t.text
          end

          if e.is_array?
            instance_variable_get(e.to_instance).send(:push,val)
          else
            instance_variable_set(e.to_instance, e.lambda(val))
          end
        else
          unsupported(t)
        end
      end
    end
  end
end