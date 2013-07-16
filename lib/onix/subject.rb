module ONIX
  class Subject < Subset
    attr_accessor :code, :heading_text, :scheme_identifier, :scheme_name, :scheme_version


    def parse(n)
      n.children.each do |t|
        case t.name
          when "SubjectHeadingText"
            @heading_text=t.text.strip
          when "SubjectCode"
            @code=t.text.strip
          when "SubjectSchemeIdentifier"
            @scheme_identifier=SubjectSchemeIdentifier.from_code(t.text)
          when "SubjectSchemeName"
            @scheme_name=t.text.strip
          when "SubjectSchemeVersion"
            @scheme_version=t.text.strip
        end
      end
    end
  end
end