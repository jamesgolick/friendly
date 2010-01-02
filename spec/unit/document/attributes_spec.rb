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
end
