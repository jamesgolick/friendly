require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Index" do
  before do
    @klass = stub(:table_name => "users")
    @index = Friendly::Index.new(@klass, [:name, :age])
  end

  describe "with one field" do
    before do
      @index = Friendly::Index.new(@klass, [:name])
    end

    it "has an appropriate table name" do
      @index.table_name.should == "index_users_on_name"
    end
  end

  describe "with multiple fields" do
    before do
      @index = Friendly::Index.new(@klass, [:name, :age])
    end

    it "has an appropriate table name" do
      @index.table_name.should == "index_users_on_name_and_age"
    end
  end

  it "satisfies conditions when all the fields are indexed" do
    @index.should be_satisfies({:name => "x", :age => "y"})
  end

  it "doesn't satisfy conditions when some fields are not indexed" do
    @index.should_not be_satisfies({:name => "x", :dob => "12/01/1980"})
  end

  it "satisfies conditions even when they're specified by string keys" do
    @index.should be_satisfies({"name" => "x"})
  end

  it "doesn't satisfy if it only uses keys on the right of the index" do
    @index.should_not be_satisfies({:age => "y"})
  end

  it "satisfies if it only uses keys on the left of the index" do
    @index.should be_satisfies({:name => "y"})
  end
end
