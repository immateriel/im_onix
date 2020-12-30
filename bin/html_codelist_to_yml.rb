#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

require 'im_onix'
require 'nokogiri'
require 'yaml'
require 'unidecoder'

# html_codelist_to_yml.rb html_codelist_dir dest_dir

class HTMLCodelist

  private

  def self.parse_codelist(codelist)
    h = {}
    html = Nokogiri::HTML.parse(File.open(codelist))
    html.search("//tr").each do |tr|
      td_code = tr.at("./td[1]")
      td_human = tr.at("./td[2]")
      if td_code and td_human
        h[td_code.text.strip] = self.rename(td_human.text.strip)
      end
    end
    h
  end

  # from rails
  def self.rename(term)
    term.gsub(/\(|\)|\,|\-|’|\/|“|”|‘|\.|\:|–|\||\+/, "").gsub(/\;/, " Or ").gsub(/\s+/, " ").split(" ").map { |t| t.capitalize }.join("").to_ascii.gsub(/\(|\)|\,|\-|’|\/|“|”|‘|\.|\:|–|\||\+/, "")
  end
end

files = `ls #{ARGV[0]}/*.htm`.split(/\n/)

files.sort.each do |file|
  codelist = file.gsub(/.*onix\-codelist\-(.*)\.htm/, '\1').to_i
  h = HTMLCodelist.parse_codelist(file)

  File.open("#{ARGV[1]}/codelist-#{codelist}.yml", 'w') do |fw|
    fw.write({:codelist => h}.to_yaml)
  end
end

