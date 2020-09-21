# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "im_onix"
  spec.version       = "1.1.0"
  spec.authors       = ["Julien Boulnois"]
  spec.email         = ["jboulnois@immateriel.fr"]

  spec.summary       = %q{immat\u{e9}riel.fr ONIX parser}
  spec.description   = %q{immat\u{e9}riel.fr ONIX parser}
  spec.homepage      = "http://github.com/immateriel/im_onix"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'shoulda'

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'nokogiri'
end
