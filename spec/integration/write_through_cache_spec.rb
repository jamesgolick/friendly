require File.expand_path("../../spec_helper", __FILE__)

describe "Writing through to cache on create" do
  before do
    @user = User.create :name => "Chris"
  end
  
  it "writes through to memcache using the model name and guid as cache key" do
    $cache.get("User/#{@user.id.to_guid}").should == @user
  end
end

describe "Writing through to cache on update" do
  before do
    @user = User.create :name => "Chris"
    @user.name = "Joe"
    @user.save
  end
  
  it "writes through to memcache using the model name and guid as cache key" do
    $cache.get("User/#{@user.id.to_guid}").name.should == @user.name
  end
end

describe "Writing through to cache on destroy" do
  before do
    @user = User.create :name => "Chris"
    @user.destroy
  end
  
  it "removes the object from cache" do
    lambda {
      $cache.get("User/#{@user.id.to_guid}") 
    }.should raise_error(Memcached::NotFound)
  end
end
