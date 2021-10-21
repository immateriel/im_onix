require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler'

$VERBOSE = nil

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/autorun'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'im_onix'

if ENV['PROFILE'] == 'yes'
  require 'ruby-prof'
  RubyProf.start

  Minitest.after_run do
    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, min_percent: 1.0)

    printer = RubyProf::CallTreePrinter.new(result)
    printer.print
  end
end
