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

  it "sets the created_at on the way out of the database" do
    @found_user.created_at.should_not be_nil
    @found_user.created_at.should == @user.created_at
  end

  it "sets the updated_at on the way out of the database" do
    @found_user.updated_at.should_not be_nil
    @found_user.updated_at.should == @user.updated_at
  end

  it "sets the updated_at" do
    @user.updated_at.should == @user.created_at
  end
end

describe "Updating an object" do
  before do
    @user = User.new :name => "Stewie Griffin",
                     :age  => 3
    @user.save
    @created_id = @user.id
    @created_at = @user.created_at

    sleep(0.1)
    @user.name = "Brian Griffin"
    @user.age  = 8
    @user.save

    @found_user = User.find(@created_id)
  end

  it "sets the updated_at column" do
    @user.updated_at.should_not be_nil
    @user.updated_at.should_not == @user.created_at
    @user.updated_at.should > @user.created_at
  end

  it "doesn't change the created_at" do
    @user.created_at.should == @created_at
  end

  it "doesn't change the id" do
    @user.id.should == @created_id
  end

  it "saves the new attrs to the db" do
    @found_user.name.should == "Brian Griffin"
    @found_user.age.should  == 8
  end
end

