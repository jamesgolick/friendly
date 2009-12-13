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

    it "stores the object in cache (read through)" do
      $cache.get("User/#{@user.id.to_guid}").should == @user
    end
  end
end

describe "Finding several objects via id in the cache" do
  def cache_key(user)
    ["User", user.id.to_guid].join("/")
  end

  before do
    @users = (0..3).map { User.create :name => "Cleveland" }
  end

  describe "when all objects are found" do
    before do
      @users.each { |u| $cache.set("User/#{u.id.to_guid}", "the user") }
    end

    it "returns all the objects from cache" do
      User.all(:id => @users.map { |u| u.id }).should == ["the user"] * 3
    end
  end

  describe "when some objects are missing" do
    before do
      $cache.delete(cache_key(@users.first))
    end

    it "finds the object and returns it" do
      User.all(:id => @users.map { |u| u.id }).should == @users
    end

    it "writes the object through to the cache" do
      lambda {
        $cache.get(cache_key(@users.first))
      }.should_not raise_error
    end
  end
end
