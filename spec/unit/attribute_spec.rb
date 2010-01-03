require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Attribute" do
  before do
    @klass   = Class.new { def will_change(a); end }
    @name    = Friendly::Attribute.new(@klass, :name, String)
    @id      = Friendly::Attribute.new(@klass, :id, Friendly::UUID)
    @no_type = Friendly::Attribute.new(@klass, :no_type, nil)
    @default = Friendly::Attribute.new(@klass, :default, String, :default => "asdf")
    @false   = Friendly::Attribute.new(@klass, :false,   String, :default => false)
    @klass.stubs(:attributes).returns({:name    => @name, 
                                       :id      => @id, 
                                       :default => @default,
                                       :false   => @false})
    @object = @klass.new
  end

  it "creates a getting on klass that notifies it of a change" do
    @object.stubs(:will_change)
    @object.name = "Something"
    @object.should have_received(:will_change).with(:name)
  end

  it "creates a getter on klass" do
    @object.name = "Something"
    @object.name.should == "Something"
  end

  it "creates an 'attr_was' getter" do
    @object.instance_variable_set(:@name_was, "Joe the Plumber")
    @object.name_was.should == "Joe the Plumber"
  end

  it "creates an attr_changed? query method" do
    @object.stubs(:attribute_changed?).with(:name).returns(true)
    @object.should be_name_changed
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

  it "has a default value of type.new" do
    @id.default.should be_instance_of(Friendly::UUID)
  end

  it "has a default of nil if the type doesn't respond to :new" do
    Friendly::Attribute.new(@klass, :age, Integer).default.should be_nil
  end

  it "doesn't try to convert when there's no type" do
    @no_type.typecast(true).should == true
  end

  it "can have a default value" do
    @default.default.should == "asdf"
    @obj = @klass.new
    @default.assign_default_value(@obj)
    @obj.default.should == "asdf"
  end

  it "has a default value even if it's false" do
    @false.default.should be_false
  end

  it "knows how to assign its own default" do
    @object = stub(:false= => nil)
    @false.assign_default_value(@object)
    @object.should have_received(:false=).with(false)
  end

  describe "registering a type" do
    before do
      @klass = Class.new
      Friendly::Attribute.register_type(@klass, "binary(16)") { |t| t.to_i }
    end

    after { Friendly::Attribute.deregister_type(@klass) }

    it "tells Attribute about the sql_type" do
      Friendly::Attribute.sql_type(@klass).should == "binary(16)"
    end

    it "registers the conversion method" do
      Friendly::Attribute.new(@klass, :something, @klass).convert("1").should == 1
    end

    it "is custom_type?(@klass)" do
      Friendly::Attribute.should be_custom_type(@klass)
    end
  end

  describe "deregistering a type" do
    before do
      @klass = Class.new
      Friendly::Attribute.register_type(@klass, "whatever") {}
      Friendly::Attribute.deregister_type(@klass)
    end

    it "removes the converter method" do
      Friendly::Attribute.converters.should_not be_has_key(@klass)
    end

    it "removes the sql_type" do
      Friendly::Attribute.sql_types.should_not be_has_key(@klass)
    end

    it "is not custom_type?(@klass)" do
      Friendly::Attribute.should_not be_custom_type(@klass)
    end
  end
end
