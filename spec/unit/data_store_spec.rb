require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::DataStore" do
  before do
    @users     = DatasetFake.new(:insert => 42)
    @db        = DatabaseFake.new("users" => @users)
    @datastore = Friendly::DataStore.new(@db)
  end

  describe "inserting data" do
    before do
      @klass = stub(:table_name => "users")
      @return = @datastore.insert(@klass, :name => "Stewie")
    end

    it "inserts it in to the table in the datastore" do
      @users.inserts.length.should == 1
      @users.inserts.should include(:name => "Stewie")
    end

    it "returns the id from the dataset" do
      @return.should == 42
    end
  end
end

