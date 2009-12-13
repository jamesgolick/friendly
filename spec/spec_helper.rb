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

Friendly.configure "mysql://root@localhost/friendly_test"
$db = Friendly.db
Sequel::MySQL.default_engine = "InnoDB"

$db.drop_table :users if $db.table_exists?("users")
$db.drop_table :index_users_on_name if $db.table_exists?("index_users_on_name")
if $db.table_exists?("index_users_on_name_and_created_at")
  $db.drop_table :index_users_on_name_and_created_at
end

datastore          = Friendly::DataStore.new($db)
Friendly.datastore = datastore

class User
  include Friendly::Document

  attribute :name,  String
  attribute :age,   Integer
  attribute :happy, Friendly::Boolean, :default => true

  indexes   :name
  indexes   :name, :created_at
end

User.create_tables!

class Address
  include Friendly::Document

  attribute :user_id, Integer
  attribute :street,  String

  indexes   :user_id
end

Address.create_tables!

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
