# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "im_onix"
  spec.version       = "1.2.2"
  spec.authors       = ["Julien Boulnois"]
  spec.email         = ["jboulnois@immateriel.fr"]

  spec.summary       = "ONIX 3.0 & 2.1 parser for Ruby"
  spec.description   = "ONIX 3.0 & 2.1 parser for Ruby"
  spec.homepage      = "http://github.com/immateriel/im_onix"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'shoulda'

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'nokogiri'
end
