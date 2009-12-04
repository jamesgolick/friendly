require File.expand_path("../../spec_helper", __FILE__)
require File.expand_path("../../fakes/document", __FILE__)

describe "Friendly::Repository" do
  before do
    @doc           = stub
    @finder        = stub(:find => @doc)
    @persister     = stub(:save => true)
    @klass         = stub
    @repository    = Friendly::Repository.new(@finder, @persister)
  end

  context "Saving a document" do
    before do
      @repository.save(@doc)
    end

    it "delegates to the persister" do
      @persister.should have_received(:save).with(@doc)
    end
  end

  context "Finding documents by id" do
    before do
      @return_val = @repository.find(@klass, 1)
    end

    it "delegates to the finder" do
      @finder.should have_received(:find).with(@klass, 1)
      @finder.should have_received(:find).once
      @return_val.should == @doc
    end
  end
end
