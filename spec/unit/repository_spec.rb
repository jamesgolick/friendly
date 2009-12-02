require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Repository" do
  before do
    @json       = "THE JSONS"
    @serializer = stub
    @serializer.stubs(:generate).with({:name => "Stewie"}).returns(@json)
    @id         = 5
    @dataset    = stub(:insert   => @id)
    @database   = stub
    @database.stubs(:from).with("users").returns(@dataset)
    @repository = Friendly::Repository.new(@database, @serializer)
    @doc        = stub(:to_hash    => {:name => "Stewie"}, 
                       :table_name => "users",
                       :id=        => nil)
  end

  describe "saving an object" do
    before do
      @repository.save(@doc)
    end

    it "knows how to save objects" do
      @dataset.should have_received(:insert).with(:attributes => "THE JSONS")
    end

    it "sets the id of the document" do
      @doc.should have_received(:id=).with(@id)
    end
  end
end
