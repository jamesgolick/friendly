require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::StorageProxy" do
  before do
    @klass          = stub
    @index          = stub(:create => nil, :update => nil)
    @index_klass    = stub(:new => @index)
    @table          = stub(:satisfies? => false, :create => nil, :update => nil)
    @doctable_klass = stub
    @doctable_klass.stubs(:new).with(@klass).returns(@table)
    @storage        = Friendly::StorageProxy.new(@klass,@index_klass,@doctable_klass)
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
      @index_klass.should have_received(:new).once
      @index_klass.should have_received(:new).with(@klass, :name, :age)
    end

    it "adds the index to the set" do
      @storage.tables.should include(@index)
    end
  end

  describe "populating indexes" do
    before do
      @index_two = stub(:create => nil, :update => nil)
      @index_klass.stubs(:new).returns(@index).then.returns(@index_two)
      @storage.add(:name)
      @storage.add(:age)
      @doc = stub
    end

    describe "creating the indexes for a document" do
      before do
        @storage.create(@doc)
      end

      it "delegates to each of the indexes" do
        @index.should have_received(:create).with(@doc)
        @index_two.should have_received(:create).with(@doc)
        @table.should have_received(:create).with(@doc)
      end
    end

    describe "updating the indexes for a document" do
      before do
        @storage.update(@doc)
      end

      it "delegates to each of the indexes" do
        @index.should have_received(:update).with(@doc)
        @index_two.should have_received(:update).with(@doc)
        @table.should have_received(:update).with(@doc)
      end
    end
  end
end
