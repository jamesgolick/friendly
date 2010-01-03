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
      @klass.attributes[:id]   = stub(:assign_default_value => nil)
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
  end

  describe "#will_change" do
    before do
      @klass.send(:attr_accessor, :some_variable)
      @object = @klass.new
      @object.some_variable = "Some value"
      @object.will_change(:some_variable)
    end

    it "makes the object #changed?" do
      @object.should be_changed
    end

    it "returns the value of the variable for #attribute_was" do
      @object.attribute_was(:some_variable).should == "Some value"
    end

    it "returns true for attribute_changed?(:some_variable)" do
      @object.should be_attribute_changed(:some_variable)
    end
  end

  describe "#reset_changes" do
    before do
      @klass.send(:attr_accessor, :some_variable)
      @object = @klass.new
      @object.some_variable = "Some value"
      @object.will_change(:some_variable)
      @object.reset_changes
    end

    it "resets the changed status of the object" do
      @object.should_not be_changed
    end

    it "returns nil for attribute_was(:some_variable)" do
      @object.attribute_was(:some_variable).should be_nil
    end

    it "returns false for attribute_changed?(:some_variable)" do
      @object.should_not be_attribute_changed(:some_variable)
    end
  end

  describe "#new_without_change_tracking" do
    before do
      @klass = Class.new do
        attr_reader :name

        def name=(name)
          will_change(:name)
          @name = name
        end

        include Friendly::Document::Attributes
      end
      @doc = @klass.new_without_change_tracking(:name => "James")
    end

    it "initializes and then calls reset_changes" do
      @doc.name.should == "James"
      @doc.should_not be_changed
    end
  end
end
