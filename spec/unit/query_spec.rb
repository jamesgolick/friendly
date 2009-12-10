require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Query" do
  before do
    @order = :created_at.desc
    @query = Friendly::Query.new(:name            => "x",
                                 :limit!          => 10,
                                 :order!          => @order,
                                 :preserve_order! => true,
                                 :offset!         => 2)
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

  it "extracts the preserve order parameter" do
    @query.should be_preserve_order
  end

  it "extracts the offset parameter" do
    @query.should be_offset
    @query.offset.should == 2
  end

  it "should not be preserver order by default" do
    Friendly::Query.new({}).should_not be_preserve_order
  end

  it "converts string representations of UUID to UUID" do
    uuid       = stub
    uuid_klass = stub
    uuid_klass.stubs(:new).with("asdf").returns(uuid)
    query      = Friendly::Query.new({:id => "asdf"}, uuid_klass)
    query.conditions[:id].should == uuid
  end

  it "converts arrays of ids to UUID" do
    uuid       = stub
    uuid_klass = stub
    uuid_klass.stubs(:new).with("asdf").returns(uuid)
    query      = Friendly::Query.new({:id => ["asdf"]}, uuid_klass)
    query.conditions[:id].should == [uuid]
  end
end
