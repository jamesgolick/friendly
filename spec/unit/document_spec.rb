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
                                 :created_at => nil}
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
      @repository.stubs(:find).returns(@return_value)
      @doc = @klass.find(5)
    end

    it "delegates to the repository" do
      @repository.should have_received(:find).with(@klass, 5)
    end

    it "returns whatever the repository returns" do
      @doc.should == @return_value
    end
  end

  describe "a document's default table name" do
    it "is the class name, converted with pluralize.underscore" do
      User.table_name.should == "users"
    end
  end
end
