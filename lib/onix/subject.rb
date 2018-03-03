module ONIX
  class Subject < SubsetDSL
    element "MainSubject", :bool
    element "SubjectSchemeIdentifier", :subset
    element "SubjectSchemeName", :text
    element "SubjectSchemeVersion", :text
    element "SubjectCode", :text
    element "SubjectHeadingText", :text

    # shortcuts
    def code
      @subject_code
    end

    def heading_text
      @subject_heading_text
    end

    def scheme_identifier
      @subject_scheme_identifier
    end

    def scheme_name
      @subject_scheme_name
    end

    def scheme_version
      @subject_scheme_version
    end
  end
end