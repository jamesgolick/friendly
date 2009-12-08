require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::DocumentTable" do
  before do
    @datastore = stub
    @klass     = stub(:name => "User")
    @table     = Friendly::DocumentTable.new(@datastore, @klass)
  end

  it "has a table name of klass.name.tableize" do
    @table.table_name.should == "users"
  end
end
