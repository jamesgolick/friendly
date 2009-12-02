require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Document" do
  describe "saving a document" do
    before do
      @repository                = stub
      Friendly.config.repository = @repository

      @user = User.new(:age  => 3,
                       :name => "Stewie")
      @repository.stubs(:save)
      @user.save
    end

    it "asks the repository to save" do
      @repository.should have_received(:save).with(@user)
    end
  end
end
