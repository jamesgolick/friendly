require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Document" do
  before do
    @klass = Class.new { include Friendly::Document }
    @klass.attribute(:name, String)
    @storage_proxy = stub
    @klass.storage_proxy = @storage_proxy
    Friendly.config.repository = @repository
  end

  it "delegates table_name to it's class" do
    User.new.table_name.should == User.table_name
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

  describe "saving a new document" do
    before do
      @user = @klass.new(:name => "whatever")
      @storage_proxy.stubs(:create)
      @user.save
    end

    it "asks the storage_proxy to create" do
      @storage_proxy.should have_received(:create).with(@user)
    end
  end

  describe "saving an existing document" do
    before do
      @user = @klass.new(:name => "whatever", :id => 42)
      @storage_proxy.stubs(:update)
      @user.save
    end

    it "asks the storage_proxy to update" do
      @storage_proxy.should have_received(:update).with(@user)
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
      @storage_proxy.stubs(:add)
      @klass = Class.new { include Friendly::Document }
      @klass.storage_proxy = @storage_proxy
      @klass.indexes :name
    end

    it "delegates to the storage_proxy" do
      @klass.storage_proxy.should have_received(:add).with(:name)
    end
  end
end

