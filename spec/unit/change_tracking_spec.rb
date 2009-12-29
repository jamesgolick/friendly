require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::ChangeTracking" do
  before do
    @klass  = Class.new do
      include Friendly::ChangeTracking

      change_tracking_accessor :some_variable
    end

    @object = @klass.new
  end

  describe "setting a variable" do
    before do
      @object.instance_variable_set(:@some_variable, "the old value")
      @object.some_variable = "a value"
    end

    it "sets the instance variable" do
      @object.instance_variable_get(:@some_variable).should == "a value"
    end

    it "marks the variable as changed" do
      @object.should be_some_variable_changed
    end

    it "saves the old value of the variable" do
      @object.some_variable_was.should == "the old value"
    end

    it "reports the object as dirty" do
      @object.should be_changed
    end
  end

  describe "resetting changes" do
    before do
      @object.some_variable = "whatever"
      @object.reset_changes
    end

    it "resets the changed status of the variable" do
      @object.should_not be_some_variable_changed
    end

    it "resets the changed status of the object" do
      @object.should_not be_changed
    end

    it "returns nil for variable_was" do
      @object.some_variable_was.should be_nil
    end
  end

  describe "getting a variable" do
    before do
      @object.some_variable = "whatever"
    end

    it "returns the current value of the attr" do
      @object.some_variable.should == "whatever"
    end
  end
end
