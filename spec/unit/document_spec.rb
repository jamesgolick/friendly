require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Document" do
  before do
    @klass = Class.new { include Friendly::Document }
    @klass.attribute(:name, String)
    @repository                = stub
    Friendly.config.repository = @repository
  end

  it "delegates table_name to it's class" do
    User.new.table_name.should == User.table_name
  end

  it "delegates to the class for indexes" do
    User.new.indexes.should == User.indexes
  end

  it "always has an id attribute" do
    @klass.new.should respond_to(:id)
    @klass.new.should respond_to(:id=)
    @klass.attributes.map { |a| a.name }.should include(:id)
  end

  it "always has a created_at attribute" do
    @klass.new.should respond_to(:created_at)
    @klass.new.should respond_to(:created_at=)
    attr = @klass.attributes.detect { |a| a.name == :created_at }
    attr.type.should == Time
  end

  it "always has a updated_at attribute" do
    @klass.new.should respond_to(:updated_at)
    @klass.new.should respond_to(:updated_at=)
    attr = @klass.attributes.detect { |a| a.name == :updated_at }
    attr.type.should == Time
  end

  describe "saving a document" do
    before do
      @user = @klass.new(:name => "whatever")
      @repository.stubs(:save)
      @user.save
    end

    it "asks the repository to save" do
      @repository.should have_received(:save).with(@user)
    end
  end

  describe "creating an attribute" do
    before do
      @attr  = @klass.attributes.last
    end

    it "creates a attribute object" do
      @attr.name.should == :name
      @attr.type.should == String
    end

    it "creates an accessor on the klass" do
      @klass.new.should respond_to(:name)
      @klass.new.should respond_to(:name=)
    end
  end

  describe "converting a document to a hash" do
    before do
      @object = @klass.new(:name => "Stewie")
    end

    it "creates a hash that contains its attributes" do
      @object.to_hash.should == {:name       => "Stewie", 
                                 :id         => nil, 
                                 :created_at => nil,
                                 :updated_at => nil}
    end
  end

  describe "setting the attributes all at once" do
    before do
      @object = @klass.new
      @object.attributes = {:name => "Bond"}
    end

    it "sets the attributes using the setters" do
      @object.name.should == "Bond"
    end

    it "raises ArgumentError when there are duplicate keys of differing type" do
      lambda { 
        @object.attributes = {:name => "Bond", "name" => "Bond"}
      }.should raise_error(ArgumentError)
    end
  end

  describe "initializing a document" do
    before do
      @doc = @klass.new :name => "Bond"
    end

    it "sets the attributes using the setters" do
      @doc.name.should == "Bond"
    end
  end

  describe "finding a document" do
    before do
      @return_value = @klass.new(:name => "Stewie")
    end

    describe "without bang" do
      before do
        @repository.stubs(:find).returns(@return_value)
        @doc = @klass.find(5)
      end

      it "delegates to the repository" do
        @repository.should have_received(:find).with(@klass, 5)
      end

      it "delegates multiple ids to the repository" do
        @klass.find(5,6,7)
        @repository.should have_received(:find).with(@klass, 5, 6, 7)
      end

      it "returns whatever the repository returns" do
        @doc.should == @return_value
      end
    end

    describe "with bang" do
      before do
        @repository.stubs(:find!).returns(@return_value)
        @doc = @klass.find!(5)
      end
      
      it "delegates to the repository" do
        @repository.should have_received(:find!).with(@klass, 5)
      end

      it "delegates multiple ids to the repository" do
        @klass.find!(5,6,7)
        @repository.should have_received(:find!).with(@klass, 5, 6, 7)
      end

      it "returns whatever the repository returns" do
        @doc.should == @return_value
      end
    end
  end

  describe "a document's default table name" do
    it "is the class name, converted with pluralize.underscore" do
      User.table_name.should == "users"
    end
  end

  describe "an object without an id" do
    it "is a new_record" do
      @klass.new.should be_new_record
    end
  end

  describe "an object with an id" do
    it "is not a new_record" do
      @klass.new(:id => 1).should_not be_new_record
    end
  end

  describe "object equality" do
    it "is never equal if both objects are new_records" do
      @klass.new(:name => "x").should_not == @klass.new(:name => "x")
    end

    it "is equal if both objects have the same id" do
      @klass.new(:id => 1).should == @klass.new(:id => 1)
    end

    it "is equal if the objects point to the same reference" do
      obj = @klass.new
      obj.should == obj
    end

    it "is not equal if two objects are of differing types with the same id" do
      @klass.new(:id => 1).should_not == User.new(:id => 1)
    end
  end

  describe "adding an index" do
    before do
      @klass = Class.new do
        include Friendly::Document

        indexes :name
      end
    end

    it "adds the index to the document's indexes set" do
      @klass.indexes.map.first.fields.should == [:name]
    end
  end

  describe "querying by index" do
    before do
      @doc           = stub
      @repository    = stub(:find => @doc)
      Friendly.config.repository = @repository
      @index_set     = stub(:first => 42)
      @klass         = Class.new { include Friendly::Document }
      @klass.indexes = @index_set
      @result        = @klass.first(:name => "Stewie")
    end

    it "delegates to the index_set for the query" do
      @index_set.should have_received(:first).once
      @index_set.should have_received(:first).with(:name => "Stewie")
    end

    it "queries the repository for the id returned by the index" do
      @repository.should have_received(:find).with(@klass, 42)
    end

    it "returns the result from the repository" do
      @result.should == @doc
    end
  end
end

