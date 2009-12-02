require File.expand_path("../../spec_helper", __FILE__)

describe "Creating and retrieving an object" do
  before do
    @user       = User.new :name => "Stewie Griffin",
                           :age  => 3
    @user.save
    @found_user = User.find(@user.id)
  end

  it "finds the user in the database" do
    @found_user.name.should == @user.name
    @found_user.age.should  == @user.age
    @found_user.id.should   == @user.id
  end

  it "locates an object that is == to the created object" do
    @found_user.should == @user
  end

  it "sets the created_at timestamp for the record" do
    @user.created_at.should_not be_nil
    @user.created_at.should be_instance_of(Time)
  end
end

