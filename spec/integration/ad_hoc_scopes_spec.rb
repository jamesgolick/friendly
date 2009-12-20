require File.expand_path("../../spec_helper", __FILE__)

describe "Querying with an ad-hoc scope" do
  before do
    User.all(:name => "Fred").each { |u| u.destroy }
    @users = (1..10).map { User.create(:name => "Fred") }
  end

  it "can return all the objects matching the scope" do
    User.scope(:name => "Fred").all.should == @users
  end

  it "can return the first object matching the scope" do
    User.scope(:name => "Fred").first.should == User.first(:name => "Fred")
  end
end
