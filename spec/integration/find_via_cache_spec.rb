require File.expand_path("../../spec_helper", __FILE__)

describe "Finding an object by id via the cache" do
  before do
    @user = User.create :name => "Cleveland"
  end

  describe "if the user is in cache" do
    before do
      $cache.set("User/#{@user.id.to_guid}", "the user")
    end

    it "returns the object from cache if its there" do
      User.first(:id => @user.id).should == "the user"
    end
  end

  describe "if the user isn't there" do
    before do
      $cache.delete("User/#{@user.id.to_guid}")
      @found = User.first(:id => @user.id)
    end

    it "finds the object in the database" do
      @found.should == @user
    end

    it "sets the object in cache (read through)" do
      $cache.get("User/#{@user.id.to_guid}").should == @user
    end
  end
end
