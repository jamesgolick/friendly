require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::DocumentTable" do
  before do
    @datastore  = stub(:insert => 42, :update => nil, :delete => nil)
    @klass      = stub(:table_name => "users")
    @translator = stub
    @table      = Friendly::DocumentTable.new(@klass, @datastore, @translator)
    @subject    = @table
    @document   = FakeDocument.new
  end

  it "has a table name of klass.table_name" do
    @table.table_name.should == "users"
  end

  it { should be_satisfies(query(:id => 1)) }
  it { should_not be_satisfies(query(:id => 1, :name => "x")) }
  it { should_not be_satisfies(query(:name => "x")) }
  it { should_not be_satisfies(query(:id => 1, :order! => :created_at.desc)) }

  describe "saving an object" do
    before do
      @document_hash = {:name => "whatever"}
      @document      = FakeDocument.new :table_name => "users",
                                        :to_hash    => @document_hash
      @record = {:created_at => Time.new, :updated_at => Time.new}
      @translator.stubs(:to_record).with(@document).returns(@record)
    end

    describe "when it is a new_record?" do
      before do
        @document.new_record = true
        @table.create(@document)
      end

      it "saves the record from the translator to the database" do
        @datastore.should have_received(:insert).with(@document, @record)
      end

      it "sets the id on the document" do
        @document.id.should == 42
      end

      it "sets the created_at on the document" do
        @document.created_at.should == @record[:created_at]
      end

      it "sets the updated_at on the document" do
        @document.updated_at.should == @record[:updated_at]
      end
    end

    describe "updating a record" do
      before do
        @document.id         = 24
        @document.new_record = false
        @table.update(@document)
      end

      it "saves the record from the translator" do
        @datastore.should have_received(:update).with(@document, 24, @record)
      end
      
      it "sets the created_at from the translator" do
        @document.created_at.should == @record[:created_at]
      end

      it "sets the updated_at from the translator" do
        @document.updated_at.should == @record[:updated_at]
      end
    end
  end

  describe "destroying an object" do
    before do
      @document.id = 42
      @table.destroy(@document)
    end

    it "asks the datastore to delete" do
      @datastore.should have_received(:delete).with(@document, 42)
    end
  end

  describe "finding the first object" do
    describe "when the object is found" do
      before do
        @record   = {:id => 1}
        @document = stub
        @datastore.stubs(:first).with(@klass, :id => 1).returns(@record)
        @translator.stubs(:to_object).with(@klass, @record).returns(@document)
      end

      it "queries the datastore and translates the object" do
        @table.first(:id => 1).should == @document
      end
    end

    describe "when the object is not found" do
      before do
        @datastore.stubs(:first).with(@klass, :id => 1).returns(nil)
      end

      it "returns nil" do
        @table.first(:id => 1).should be_nil
      end
    end
  end

  describe "finding many objects" do
    before do
      @records  = [row(:id => 1), row(:id => 2)]
      @document = stub
      @query    = query(:id => [1,2])
      @records.each do |r|
        @translator.stubs(:to_object).with(@klass, r).returns(@document).once
      end
      @datastore.stubs(:all).with(@klass, @query).returns(@records)
    end

    it "queries the datastore and translates the returned records" do
      @table.all(@query).should == [@document, @document]
    end
  end

  describe "finding many objects with preserve_order" do
    before do
      @records = [row(:id => 1), row(:id => 2)]
      @doc_one = stub(:id => 1)
      @doc_two = stub(:id => 2)
      @query   = query(:id => [2,1], :preserve_order! => true)
      @translator.stubs(:to_object).with(@klass, @records.first).returns(@doc_one)
      @translator.stubs(:to_object).with(@klass, @records.last).returns(@doc_two)
      @datastore.stubs(:all).with(@klass, @query).returns(@records)
    end

    it "returns objects in the order they were queried for" do
      @table.all(@query).should == [@doc_two, @doc_one]
    end
  end
end
