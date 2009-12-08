require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Index" do
  before do
    @klass = stub(:table_name => "users")
    @index = Friendly::Index.new(@klass, [:name, :age])
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

  describe "finding the first record matching a query" do
    before do
      @result    = row(:id => 42)
      @datastore = stub(:first => @result)
      @index     = Friendly::Index.new(@klass, [:name], @datastore)
      @result    = @index.first(:name => "x")
    end

    it "queries the datastore with the attributes from the query" do
      @datastore.should have_received(:first).once
      @datastore.should have_received(:first).with(@index, :name => "x")
    end

    it "returns the id returned form the datastore" do
      @result.should == 42
    end
  end

  describe "finding all the rows matching a query" do
    before do
      @results   = [row(:id => 42), row(:id => 43), row(:id => 44)]
      @datastore = stub(:all => @results)
      @index     = Friendly::Index.new(@klass, [:name], @datastore)
      @result    = @index.all(:name => "x")
    end

    it "queries the datastore with the conditions" do
      @datastore.should have_received(:all).once
      @datastore.should have_received(:all).with(@index, :name => "x")
    end

    it "returns an array of matching ids" do
      @result.should == [42, 43, 44]
    end
  end
end
