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

  describe "when no objects are found" do
    it "raises RecordNotFound with the bang version" do
      lambda { 
        User.find!(99999999, 9999999, 99999)
      }.should raise_error(Friendly::RecordNotFound)
    end

    it "returns an empty array with the non-bang ver" do
      User.find(9999,12345, 999).should == []
    end
  end

  describe "when one object is found, but others aren't" do
    it "raises RecordNotFound using the bang version" do
      lambda {
        User.find!(@user_one.id, 10000000)
      }.should raise_error(Friendly::RecordNotFound)
    end

    it "returns the found objects with the non-bang ver" do
      User.find(@user_one.id, 12345).should == [@user_one]
    end
  end
end
