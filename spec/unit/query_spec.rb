require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Query" do
  before do
    @order = :created_at.desc
    @query = Friendly::Query.new(:name   => "x",
                                 :limit! => 10,
                                 :order! => @order)
  end

  it "extracts the conditions" do
    @query.conditions.should == {:name => "x"}
  end

  it "extracts the limit parameter" do
    @query.limit.should == 10
  end

  it "extracts the order parameter" do
    @query.order.should == @order
  end
end
