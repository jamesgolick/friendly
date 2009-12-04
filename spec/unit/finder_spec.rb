require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Finder" do
  before do
    @doc        = stub
    @klass      = stub(:name => "User")
    @row        = stub
    @translator = stub
    @datastore  = stub
    @finder     = Friendly::Finder.new(@datastore, @translator)
  end

  describe "finding a record by id" do
    describe "when an object is returned" do
      before do
        @translator.stubs(:to_object).with(@klass, @row).returns(@doc)
        @datastore.stubs(:first).with(@klass, :id => 1).returns(@row)
        @return = @finder.find(@klass, 1)
      end

      it "returns the translated row" do
        @return.should == @doc
      end
    end

    describe "when no object is returned" do
      before do
        @datastore.stubs(:first).returns(nil)
      end

      it "raises RecordNotFound" do
        lambda {
          @finder.find(@klass, 1)
        }.should raise_error(Friendly::RecordNotFound)
      end
    end
  end
end
