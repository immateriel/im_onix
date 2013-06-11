module ONIX
  class Subject < Subset
    attr_accessor :code, :heading_text, :scheme_identifier, :scheme_name, :scheme_version


    def parse(subj)

      @heading_text=Helper.text_at(subj, "./SubjectHeadingText")
      @code=Helper.text_at(subj, "./SubjectCode")
      @scheme_identifier=SubjectSchemeIdentifier.from_code(Helper.text_at(subj, "./SubjectSchemeIdentifier"))
      @scheme_name=Helper.text_at(subj, "./SubjectSchemeName")
      @scheme_version=Helper.text_at(subj, "./SubjectSchemeVersion")

    end
  end
end