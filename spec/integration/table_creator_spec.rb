require File.expand_path("../../spec_helper", __FILE__)

describe "Creating the tables for a model" do
  before do
    @klass = Class.new do
      include Friendly::Document

      def self.table_name; "stuffs"; end

      attribute :name, String

      indexes [:name, :created_at]
    end

    @klass.create_tables!
    @schema = Friendly.db.schema[:stuffs]
    @table  = Hash[*@schema.map { |s| [s.first, s.last] }.flatten]
  end

  after { Friendly.db.drop_table(:stuffs) }

  it "creates a table for the document" do
    @table[:added_id][:db_type].should == "int(11)"
    @table[:added_id][:primary_key].should be_true
    @table[:id][:db_type].should == "binary(16)"
    @table[:attributes][:db_type].should == "text"
    @table[:created_at][:db_type].should == "datetime"
    @table[:updated_at][:db_type].should == "datetime"
  end
end
