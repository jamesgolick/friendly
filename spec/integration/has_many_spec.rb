require File.expand_path("../../spec_helper", __FILE__)

describe "Has many associations" do
  before do
    @user      = User.create :name => "Fred"
    @addresses = (0..2).map { Address.create :user_id => @user.id }
  end

  it "returns the objects whose foreign keys match the object's id" do
    @user.addresses.all.should == @addresses
  end
end
