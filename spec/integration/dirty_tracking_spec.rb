require File.expand_path("../../spec_helper", __FILE__)

describe "Changing an attribute" do
  describe "before a record is saved" do
    before do
      @user      = User.new
      @user.name = "James"
    end

    it "responds to the attribute being changed" do
      @user.should be_name_changed
    end

    it "returns the original value of the attribute" do
      @user.name_was.should == ""
    end

    it "is changed" do
      @user.should be_changed
    end
  end

  describe "after saving a record with changed attributes" do
    before do
      @user      = User.create
      @user.name = "James"
      @user.save
    end

    it "is no longer attribute_changed?" do
      @user.should_not be_name_changed
    end

    it "returns nil for attribute_was" do
      @user.name_was.should be_nil
    end

    it "is no longer changed" do
      @user.should_not be_changed
    end
  end
end

