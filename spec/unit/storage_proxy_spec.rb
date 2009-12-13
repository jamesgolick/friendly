require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::StorageProxy" do
  before do
    @klass          = stub
    @index          = stub(:create => nil, :update => nil, :destroy => nil)
    @table          = stub(:satisfies? => false, :create => nil, 
                           :update => nil,       :destroy => nil)
    @table_factory  = stub(:index => @index)
    @table_factory.stubs(:document_table).with(@klass).returns(@table)
    @storage        = Friendly::StorageProxy.new(@klass, @table_factory)
  end

  it "instantiates and adds a document table by default" do
    @storage.tables.should include(@table)
  end

  describe "doing a `first`" do
    before do
      @id     = stub
      @index  = stub(:satisfies? => true, :first => @id)
      @storage.tables << @index
    end

    describe "when there's an index that matches the conditions" do
      before do
        @result = @storage.first(:name => "x")
      end

      it "delegates to the index that satisfies the conditions" do
        @index.should have_received(:first).once
        @index.should have_received(:first).with(:name => "x")
      end

      it "returns id" do
        @result.should == @id
      end
    end

    describe "when there's no index that matches" do
      before do
        @index.stubs(:satisfies?).returns(false)
      end

      it "raises MissingIndex" do
        lambda {
          @storage.first(:name => "x")
        }.should raise_error(Friendly::MissingIndex)
      end
    end
  end

  describe "doing an `all`" do
    before do
      @ids    = [stub]
      @index  = stub(:satisfies? => true, :all => @ids)
      @storage.tables << @index
    end

    describe "when there's an index that matches the conditions" do
      before do
        @result = @storage.all(:name => "x")
      end

      it "delegates to the index that satisfies the conditions" do
        @index.should have_received(:all).once
        @index.should have_received(:all).with(:name => "x")
      end

      it "returns the results" do
        @result.should == @ids
      end
    end

    describe "when there's no index that matches" do
      before do
        @index.stubs(:satisfies?).returns(false)
      end

      it "raises MissingIndex" do
        lambda {
          @storage.all(:name => "x")
        }.should raise_error(Friendly::MissingIndex)
      end
    end
  end

  describe "adding an index to the set" do
    before do
      @storage.add(:name, :age)
    end

    it "creates an index" do
      @table_factory.should have_received(:index).once
      @table_factory.should have_received(:index).with(@klass, :name, :age)
    end

    it "adds the index to the set" do
      @storage.tables.should include(@index)
    end
  end

  describe "saving data" do
    before do
      @index_two = stub(:create => nil, :update => nil, :destroy => nil)
      @table_factory.stubs(:index).returns(@index).then.returns(@index_two)
      @storage.add(:name)
      @storage.add(:age)
      @doc = stub
    end

    describe "on create" do
      before do
        @storage.create(@doc)
      end

      it "delegates to each of the tables" do
        @index.should have_received(:create).with(@doc)
        @index_two.should have_received(:create).with(@doc)
        @table.should have_received(:create).with(@doc)
      end
    end

    describe "on update" do
      before do
        @storage.update(@doc)
      end

      it "delegates to each of the tables" do
        @index.should have_received(:update).with(@doc)
        @index_two.should have_received(:update).with(@doc)
        @table.should have_received(:update).with(@doc)
      end
    end

    describe "on destroy" do
      before do
        @storage.destroy(@doc)
      end

      it "delegates to each of the tables" do
        @index.should have_received(:destroy).with(@doc)
        @index_two.should have_received(:destroy).with(@doc)
        @table.should have_received(:destroy).with(@doc)
      end
    end
  end
end
