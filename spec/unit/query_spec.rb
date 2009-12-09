require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Query" do
  before do
    @query = Friendly::Query.new(:name => "x", :limit! => 10)
  end

  it "extracts the conditions" do
    @query.conditions.should == {:name => "x"}
  end

  it "extracts the limit parameter" do
    @query.limit.should == 10
  end
end
