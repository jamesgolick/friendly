require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Finder" do

  describe "finder a record by id" do
    before do
      @doc        = stub
      @klass      = stub(:new => @doc)
      @hash       = {:name => "Peter", :created_at => nil, :updated_at => nil, :id => 1}
      @serializer = stub(:parse => @hash)
      @json       = "THE JSON"
      @datastore  = stub(:first => {:id => 1, :attributes => @json})
      @finder     = Friendly::Finder.new(@datastore, @serializer)
      @return     = @finder.find(@klass, 1)
    end

    it "delegates first to the datastore with the appropriate attributes" do
      @datastore.should have_received(:first).with(@klass, :id => 1).once
    end

    it "deserialized the attributes into the object" do
      @klass.should have_received(:new).with(@hash)
      @serializer.should have_received(:parse).with(@json)
      @return.should == @doc
    end
  end

end
