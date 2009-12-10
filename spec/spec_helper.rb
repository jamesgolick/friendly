$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
Dir[File.expand_path(File.dirname(__FILE__)) + "/fakes/*.rb"].each do |f|
  require f
end
require 'rubygems'
require 'friendly'
require 'spec'
require 'spec/autorun'
require 'sequel'
require 'json'
gem     'jferris-mocha'
require 'mocha'

$db = Sequel.sqlite
$db.create_table :users do
  primary_key :added_id
  binary      :id,         :size => 16
  String      :attributes, :text => true
  Time        :created_at
  Time        :updated_at
end

$db.create_table :index_users_on_name do
  String      :name
  Fixnum      :id
  primary_key [:name, :id]
end

$db.create_table :index_users_on_name_and_created_at do
  String      :name
  Time        :created_at
  Fixnum      :id
  primary_key [:name, :created_at, :id]
end

datastore          = Friendly::DataStore.new($db)
Friendly.datastore = datastore

class User
  include Friendly::Document

  attribute :name, String
  attribute :age,  Integer

  indexes   :name
  indexes   :name, :created_at
end

module Mocha
  module API
    def setup_mocks_for_rspec
      mocha_setup
    end
    def verify_mocks_for_rspec
      mocha_verify
    end
    def teardown_mocks_for_rspec
      mocha_teardown
    end 
  end
end

module Factory
  def row(opts = {})
    { :id => 1, :created_at => Time.new, :updated_at => Time.new }.merge(opts)
  end

  def query(conditions)
    stub(:order           => conditions.delete(:order!), 
         :limit           => conditions.delete(:limit!),
         :preserve_order? => conditions.delete(:preserve_order!),
         :conditions      => conditions,
         :offset          => conditions.delete(:offset!))
  end
end

Spec::Runner.configure do |config|
  config.mock_with Mocha::API
  config.include Factory
end
