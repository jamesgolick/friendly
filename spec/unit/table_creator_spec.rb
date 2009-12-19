require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::TableCreator" do
  it "should create tables and indexes for tables with custom fields" do
    @user = User.create(:happy => true)
    @friend = User.create(:happy => false, :friend => @user.id)
    @user.should_not be_nil
    @friend.should_not be_nil
    # Reload the friend
    @friend = User.find(@friend.id)
    User.find(@friend.friend).should == @user
  end
end