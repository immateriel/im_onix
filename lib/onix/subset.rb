module ONIX
  class Subset
    def self.from_xml(n)
      o=self.new
      o.parse(n)
      o
    end

    def parse(n)
    end

    def write(n)
    end

  end
end