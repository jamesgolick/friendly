$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'friendly'
require 'spec'
require 'spec/autorun'
require 'sequel'
require 'json'
gem     'jferris-mocha'
require 'mocha'

db = Sequel.sqlite
db.create_table :users do
  primary_key :id
  String      :attributes, :text => true
  Time        :created_at
  Time        :updated_at
end

class User
  include Friendly::Document

  attribute :name, String
  attribute :age,  Integer
end

Friendly.config.repository = Friendly::Repository.new(db, JSON, Time)

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

Spec::Runner.configure do |config|
  config.mock_with Mocha::API
end
