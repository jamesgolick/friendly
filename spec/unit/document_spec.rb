require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Document" do
  describe "saving a document" do
    before do
      @repository                = stub
      Friendly.config.repository = @repository

      @user = User.new(:age  => 3,
                       :name => "Stewie")
      @repository.stubs(:save)
      @user.save
    end

    it "asks the repository to save" do
      @repository.should have_received(:save).with(@user)
    end
  end

  describe "creating an attribute" do
    before do
      @klass = Class.new { include Friendly::Document }
      @klass.attribute(:name, String)
      @attr  = @klass.attributes.first
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
end
