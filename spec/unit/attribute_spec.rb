require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Attribute" do
  before do
    @klass  = Class.new
    @name   = Friendly::Attribute.new(@klass, :name, String)
    @id     = Friendly::Attribute.new(@klass, :id, Friendly::UUID)
    @klass.stubs(:attributes).returns({:name => @name, :id => @id})
    @object = @klass.new
  end

  it "creates a setter and a getter on klass" do
    @object.name = "Something"
    @object.name.should == "Something"
  end

  it "typecasts values using the converter function" do
    uuid = Friendly::UUID.new
    @id.typecast(uuid.to_s).should == uuid
  end

  it "doesn't typecast values if they are of the right type" do
    uuid = Friendly::UUID.new
    @id.typecast(uuid).should == uuid
  end

  it "raises a useful error if it can't typecast" do
    attribute = Friendly::Attribute.new(@klass, :weird, Class)
    lambda {
      attribute.typecast("ASDF")
    }.should raise_error(Friendly::NoConverterExists)
  end

  it "creates a getter with a default value" do
    @object.id.should be_instance_of(Friendly::UUID)
  end

  it "has a default value of type.new" do
    @id.default.should be_instance_of(Friendly::UUID)
  end

  it "has a default of nil if the type doesn't respond to :new" do
    Friendly::Attribute.new(@klass, :age, Integer).default.should be_nil
  end
end
