require File.expand_path("../../spec_helper", __FILE__)

describe "Finding one object with an index" do
  before do
    @created_user = User.new(:name => "James")
    @created_user.save
    @found_user   = User.first(:name => "James")
  end

  it "finds the object" do
    @found_user.should == @created_user
  end
end

describe "Finding one object that doesn't exist in the index" do
  it "returns nil" do
    User.first(:name => "asdf").should be_nil
  end
end

describe "Finding object on an index that doesn't exist" do
  it "raises Friendly::MissingIndex" do
    lambda {
      User.first(:age => 3) 
    }.should raise_error(Friendly::MissingIndex)
  end
end

