require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Scope" do
  before do
    @klass            = stub
    @scope_parameters = {:name => "Quagmire", :order! => :created_at.desc}
    @scope            = Friendly::Scope.new(@klass, @scope_parameters)
  end

  describe "#all" do
    before do
      @documents = stub
    end

    it "delegates to klass with the scope parameters" do
      @klass.stubs(:all).with(@scope_parameters).returns(@documents)
      @scope.all.should == @documents
    end

    it "merges additional parameters" do
      merged = @scope_parameters.merge(:name => "Joe")
      @klass.stubs(:all).with(merged).returns(@documents)
      @scope.all(:name => "Joe").should == @documents
    end
  end

  describe "#first" do
    before do
      @document = stub
    end

    it "delegates to klass with the scope parameters" do
      @klass.stubs(:first).with(@scope_parameters).returns(@document)
      @scope.first.should == @document
    end

    it "merges additional parameters" do
      merged = @scope_parameters.merge(:name => "Joe")
      @klass.stubs(:first).with(merged).returns(@document)
      @scope.first(:name => "Joe").should == @document
    end
  end
end
