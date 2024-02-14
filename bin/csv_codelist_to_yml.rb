require 'csv'
require 'yaml'
require 'unidecoder'

# using https://www.editeur.org/14/Code-Lists/#CodeListFiles "tab-delimited, Unicode character set and UTF-8"
class CSVCodelist

  def initialize(filename)
    @csv = CSV.open(filename, col_sep: "\t")
  end

  def parse
    @codelists = {}
    @csv.each do |line|
      @codelists[line[0]] ||= {}
      @codelists[line[0]][line[1]] = rename(line[2])
    end
    @codelists.each do |list, data|
      filename = "data/codelists/codelist-#{list}.yml"
      if File.exist?(filename)
        existing_data = YAML.load_file(filename)
        new_data = {}
        data.each do |code, value|
          # we do not want to change existing names to keep compatibility
          new_data[:codelist] ||= {}
          new_data[:codelist][code] = existing_data[:codelist][code] || value
        end
        yaml = new_data.to_yaml
        File.write(filename, yaml)
      else
        # new codelist
        File.write(filename, ({codelist: data}).to_yaml)
      end
    end
  end

  # from rails
  def rename(term)
    result = term.to_ascii.gsub(/\(|\)|\,|'|’|\/|“|”|‘|\.|\:|–|\||\+/, "").gsub(/\-/," ").gsub(/\;/, " Or ").gsub(/\s+/, " ").split(" ").map { |t| t.capitalize }.join("")
    if result.length > 63
      puts "WARN: #{result} (#{term}) to long"
    end
    result
  end

end

CSVCodelist.new(ARGV[0]).parse
