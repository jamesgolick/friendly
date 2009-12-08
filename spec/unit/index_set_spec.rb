require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::IndexSet" do
  before do
    @set = Friendly::IndexSet.new
  end

  describe "doing a `first`" do
    before do
      @id     = stub
      @index  = stub(:satisfies? => true, :first => @id)
      @set << @index
    end

    describe "when there's an index that matches the conditions" do
      before do
        @result = @set.first(:name => "x")
      end

      it "delegates to the index that satisfies the conditions" do
        @index.should have_received(:first).once
        @index.should have_received(:first).with(:name => "x")
      end

      it "returns id" do
        @result.should == @id
      end
    end

    describe "when there's no index that matches" do
      before do
        @index.stubs(:satisfies?).returns(false)
      end

      it "raises MissingIndex" do
        lambda {
          @set.first(:name => "x")
        }.should raise_error(Friendly::MissingIndex)
      end
    end
  end
end
