require File.expand_path("../../spec_helper", __FILE__)

describe "Writing through to cache on create" do
  before do
    @user = User.create :name => "Chris"
  end
  
  it "writes through to memcache using the model name and guid as cache key" do
    $cache.get("User/#{@user.id.to_guid}").should == @user
  end
end
