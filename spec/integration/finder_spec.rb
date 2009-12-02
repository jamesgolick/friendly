require File.expand_path("../../spec_helper", __FILE__)

describe "Finding multiple objects by id" do
  before do
    @user_one = User.new
    @user_two = User.new
    @user_one.save
    @user_two.save
    @users    = User.find(@user_one.id, @user_two.id)
  end

  it "finds the objects in the database" do
    @users.length.should == 2
    @users.should include(@user_one)
    @users.should include(@user_two)
  end
end
