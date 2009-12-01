$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'friendly'
require 'spec'
require 'spec/autorun'
require 'sequel'

Spec::Runner.configure do |config|
  
end
