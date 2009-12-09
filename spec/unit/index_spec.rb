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
      @doc       = stub
      @klass.stubs(:first).with(:id => 42).returns(@doc)
      @result    = @index.first(:name => "x")
    end

    it "queries the datastore with the attributes from the query" do
      @datastore.should have_received(:first).once
      @datastore.should have_received(:first).with(@index, :name => "x")
    end

    it "finds the document by the id returned by the datastore" do
      @klass.should have_received(:first).with(:id => 42)
    end

    it "returns the document returned by the klass" do
      @result.should == @doc
    end

    describe "when no result is found" do
      before do
        @datastore.stubs(:first).returns(nil)
        @result = @index.first(:name => "x")
      end

      it "returns nil" do
        @result.should be_nil
      end
    end
  end

  describe "finding all the rows matching a query" do
    before do
      @results   = [row(:id => 42), row(:id => 43), row(:id => 44)]
      @datastore = stub(:all => @results)
      @index     = Friendly::Index.new(@klass, [:name], @datastore)
      @documents = stub
      @klass.stubs(:all).with(:id => [42, 43, 44]).returns(@documents)
      @result    = @index.all(:name => "x")
    end

    it "queries the datastore with the conditions" do
      @datastore.should have_received(:all).once
      @datastore.should have_received(:all).with(@index, :name => "x")
    end

    it "then queries the klass for the ids it found in the index" do
      @klass.should have_received(:all).with(:id => [42, 43, 44])
    end

    it "returns the result from the klass.all call" do
      @result.should == @documents
    end
  end

  describe "updating the indexes" do
    before do
      @datastore = stub(:insert => nil, :update => nil)
      @index     = Friendly::Index.new(stub, [:name], @datastore)
      @document  = stub(:name    => "Stewie", 
                        :indexes => [@index],
                        :id      => 42)
      @index_record = {:name => "Stewie", :id => 42}
    end

    describe "indexing a new document" do
      before do
        @index.create(@document)
      end

      it "inserts a record in to the datastore with the indexed vals and id" do
        @datastore.should have_received(:insert).with(@index, @index_record)
      end
    end

    describe "indexing an existing document" do
      before do
        @index.update(@document)
      end

      it "updates the index records in the database" do
        @datastore.should have_received(:update).with(@index, 42, @index_record)
      end
    end
  end

  describe "destroying the index rows" do
    before do
      @datastore = stub(:delete => nil)
      @index     = Friendly::Index.new(stub, [:name], @datastore)
      @document  = stub(:name    => "Stewie", 
                        :indexes => [@index],
                        :id      => 42)
      @index.destroy(@document)
    end

    it "deletes the records in the index" do
      @datastore.should have_received(:delete).with(@index, 42)
    end
  end
end
