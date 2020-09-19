class DSLHelpers
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

  def self.pluralize(str)
    rex = /(#{self.inflectors.map { |si, pl| si }.join('|')})$/i
    hash = Hash[*self.inflectors.flatten]
    str.sub(rex) { |m| hash[m] }
  end

  def self.underscore(str)
    word = str.to_s.dup
    word.gsub!('::', '/')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

class ElementDSLAttributeHandler < YARD::Handlers::Ruby::AttributeHandler
  handles method_call(:element)
  namespace_only

  process do
    name = statement.parameters[0].jump(:tstring_content, :ident).source
    type = statement.parameters[1].jump(:tstring_content, :ident).source
    attrs = statement.parameters[2] ? statement.parameters[2].jump(:hash).source : "{}"

    unless attrs.start_with?("{")
      attrs = "{#{attrs}}"
    end

    attrs = eval(attrs)

    returns = nil
    case type
    when "subset"
      returns = YARD::DocstringParser.new.parse("@return [#{name}]").to_docstring.tags.first
    when "text"
      returns = YARD::DocstringParser.new.parse("@return [String]").to_docstring.tags.first
    when "integer"
      returns = YARD::DocstringParser.new.parse("@return [Integer]").to_docstring.tags.first
    when "float"
      returns = YARD::DocstringParser.new.parse("@return [Float]").to_docstring.tags.first
    when "bool"
      returns = YARD::DocstringParser.new.parse("@return [Boolean]").to_docstring.tags.first
    end

    object = YARD::CodeObjects::MethodObject.new(namespace, "#{DSLHelpers.underscore(name)}", :instance)
    object.dynamic = true
    object.add_tag(returns) if returns
    object[:group] = 'Low level'
    register(object)

    if attrs[:shortcut]
      object = YARD::CodeObjects::MethodObject.new(namespace, attrs[:shortcut].to_s, :instance)
      object.dynamic = true
      object[:docstring] =  "shortcut for {##{DSLHelpers.underscore(name)}}"
      object.add_tag(returns) if returns
      object[:group] = 'Shortcuts'
      register(object)
    end
  end
end

class ElementsDSLAttributeHandler < YARD::Handlers::Ruby::AttributeHandler
  handles method_call(:elements)
  namespace_only

  process do
    name = statement.parameters[0].jump(:tstring_content, :ident).source
    type = statement.parameters[1].jump(:tstring_content, :ident).source
    attrs = statement.parameters[2] ? statement.parameters[2].jump(:hash).source : "{}"

    unless attrs.start_with?("{")
      attrs = "{#{attrs}}"
    end

    attrs = eval(attrs)

    returns = nil
    case type
    when "subset"
      returns = YARD::DocstringParser.new.parse("@return [Array<#{name}>]").to_docstring.tags.first
    when "text"
      returns = YARD::DocstringParser.new.parse("@return [Array<String>]").to_docstring.tags.first
    when "integer"
      returns = YARD::DocstringParser.new.parse("@return [Array<Integer>]").to_docstring.tags.first
    when "float"
      returns = YARD::DocstringParser.new.parse("@return [Array<Float>]").to_docstring.tags.first
    when "bool"
      returns = YARD::DocstringParser.new.parse("@return [Array<Boolean>]").to_docstring.tags.first
    end

    object = YARD::CodeObjects::MethodObject.new(namespace, "#{DSLHelpers.pluralize(DSLHelpers.underscore(name))}", :instance)
    object.dynamic = true
    object.add_tag(returns) if returns
    object[:group] = 'Low level'
    register(object)

    if attrs[:shortcut]
      object = YARD::CodeObjects::MethodObject.new(namespace, attrs[:shortcut].to_s, :instance)
      object.dynamic = true
      object[:docstring] =  "shortcut for {##{DSLHelpers.pluralize(DSLHelpers.underscore(name))}}"
      object.add_tag(returns) if returns
      object[:group] = 'Shortcuts'
      register(object)
    end
  end

end
