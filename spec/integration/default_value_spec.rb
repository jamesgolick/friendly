require File.expand_path("../../spec_helper", __FILE__)

describe "An attribute with a default value" do
  describe "before saving" do
    before do
      @user = User.new
    end

    it "has the value by default" do
      @user.happy.should be_true
    end

    it "has a default vaue even when it's false" do
      @user.sad.should be_false
    end
  end

  describe "after saving" do
    before do
      @user = User.new
      @user.save
      @user = User.find(@user.id)
    end

    it "doesn't set the existing attributes as dirty" do
      @user.should_not be_changed
      @user.should_not be_happy_changed
    end
  end
end
