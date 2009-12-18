require File.expand_path("../../spec_helper", __FILE__)

describe "named_scope" do
  describe "calling a single named_scope" do
    before do
      User.all(:name => "Quagmire").each { |q| q.destroy }
      5.times { User.create(:name => "Quagmire") }
      @users = User.named_quagmire
    end

    it "returns all the objects matching the conditions" do
      @users.should == User.all(:name => "Quagmire")
    end
  end
end
