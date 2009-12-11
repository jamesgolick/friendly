require File.expand_path("../../spec_helper", __FILE__)

describe "Document.create" do
  before do
    @user = User.create(:name => "James")
  end

  it "initializes the document, saves it, and returns it" do
    @user.name.should == "James"
    @user.should_not be_new_record
    User.find(@user.id).should_not be_nil
  end
end
