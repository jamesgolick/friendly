require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Finder" do
  describe "finding a record by id" do
    before do
      @doc        = stub
      @klass      = stub
      @row        = stub
      @translator = stub
      @translator.stubs(:to_object).with(@klass, @row).returns(@doc)
      @datastore  = stub
      @datastore.stubs(:first).with(@klass, :id => 1).returns(@row)
      @finder     = Friendly::Finder.new(@datastore, @translator)
      @return     = @finder.find(@klass, 1)
    end

    it "returns the translated row" do
      @return.should == @doc
    end
  end
end
