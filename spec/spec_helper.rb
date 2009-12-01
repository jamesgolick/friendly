$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'friendly'
require 'spec'
require 'spec/autorun'
require 'sequel'
require 'json'

db = Sequel.sqlite
db.create_table :users do
  primary_key :id
  String      :attributes, :text => true
  Time        :created_at
end

class User
  include Friendly::Document

  property :name, String
  property :age,  Integer
end


Friendly.configure do |conf|
  conf.database = db
end

Spec::Runner.configure do |config|
  
end
