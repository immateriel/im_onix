# -*- encoding : utf-8 -*-
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "im_onix"
    gem.summary = %Q{immatériel.fr onix parser}
    gem.description = %Q{immatériel.fr onix parser}
    gem.email = "jboulnois@immateriel.fr"
    gem.homepage = "http://github.com/immateriel/im_onix"
    gem.authors = ["julbouln"]
    gem.files = Dir.glob('bin/**/*') + Dir.glob('lib/**/*') + Dir.glob('data/**/*')

    gem.add_dependency "nokogiri"

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/  20 for additional settings
  end
  Jeweler::GemcutterTasks.new


rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

