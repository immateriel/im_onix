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
    def self.attr_accessor(*vars)
      @attributes ||= []
      @attributes.concat vars
      super(*vars)
    end

    def self.attributes
      @attributes||[]
    end

    def self.rec_attributes
      attrs=[]
      sup=self
      while (sup.respond_to?(:attributes))
        attrs+=sup.attributes
        sup=sup.superclass
      end
      attrs
    end

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

    def marshal_dump
      vars={}
      self.class.rec_attributes.each do |var|
        k=var.to_s.delete("@")
        v=self.instance_variable_get("@"+var.to_s)
        vars[k]=v
      end
      vars
    end

    def marshal_load(vars)
      vars.each do |attr, value|
        instance_variable_set("@"+attr, value)
      end
    end

    #
    # repeatable, non_repeating
    # optional, mandatory

    #    def inspect
    #      vars = instance_variables.collect { |v| v.to_s << "=#{instance_variable_get(v).inspect}"}.join(",\n ")
    #      "#<#{self.class} #{vars}>"
    #    end
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

    def underscore_name
      if @array and @pluralize
        @underscore_name||=pluralize(underscore(@name))
      else
        @underscore_name||=underscore(@name)
      end
    end

    def class_name
      @klass_name
    end

    def to_sym
      self.underscore_name.to_sym
    end

    def to_instance
      "@"+self.underscore_name
    end
  end

  class SubsetDSL < Subset
    def self.element(name, type, options={})
      @elements ||= {}
      @elements[name]=ElementParser.new(name, type, options)
      puts "register #{name} #{@elements[name].to_instance}"
      attr_accessor @elements[name].to_sym
    end

    # shortcut for element :array=>true
    def self.elements(name, type, options={})
      self.element(name,type,options.merge(:array=>true))
    end

    def self.registered_elements
      @elements
    end

    def initialize
      # initialize plural as Array
      self.class.registered_elements.each do |k,e|
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
        e=self.class.registered_elements[name]
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

#    element "SubjectHeadingText", :text
#    element "SubjectSchemeIdentifier", :subset
# elements "ProductSupply", :subset


  end
end