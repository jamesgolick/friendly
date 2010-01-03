require File.expand_path("../../../spec_helper", __FILE__)

describe "Friendly::Document::Attributes" do
  before do
    @klass = Class.new do
      include Friendly::Document::Attributes

      attribute :name, String
    end
  end

  describe "#initialize" do
    it "sets the attributes using the setters" do
      @doc = @klass.new :name => "Bond"
      @doc.name.should == "Bond"
    end

    it "assigns the default values" do
      @klass.attribute :id, Friendly::UUID
      @klass.attributes[:id]   = stub(:assign_default_value => nil, 
                                      :typecast             => nil)
      @klass.attributes[:name] = stub(:assign_default_value => nil, 
                                      :typecast             => "Bond")
      @doc = @klass.new :name => "Bond"
      @klass.attributes[:id].should have_received(:assign_default_value).with(@doc)
      @klass.attributes[:name].should have_received(:assign_default_value).with(@doc)
    end
  end

  describe "#attributes=" do
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

  describe "#to_hash" do
    before do
      @object = @klass.new(:name => "Stewie")
    end

    it "creates a hash that contains its attributes" do
      @object.to_hash.should == {:name => "Stewie"}
    end
  end

  describe "#assign" do
    before do
      @object = @klass.new
      @object.assign(:name, "James Bond")
    end

    it "assigns the value to the attribute" do
      @object.name.should == "James Bond"
    end

    it "typecasts the value using the Attribute object" do
      uuid = Friendly::UUID.new

      @attribute = stub(:assign_default_value => nil)
      @attribute.stubs(:typecast).with(uuid.to_guid).returns(uuid)
      @klass.attributes[:id] = @attribute
      @klass.send(:attr_accessor, :id)
      
      @object = @klass.new
      @object.assign(:id, uuid.to_guid)
      @object.id.should == uuid
    end

    it "doesn't try to typecast if there's no Attribute object" do
      @klass.send(:attr_accessor, :height)
      @object        = @klass.new
      @object.assign(:height, "5'11")
      @object.height.should == "5'11"
    end
  end
end
