require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Indexer" do
  before do
    @datastore = stub(:insert => nil, :update => nil)
    @indexer   = Friendly::Indexer.new(@datastore)
    @index     = stub(:fields  => [:name])
    @document  = stub(:name    => "Stewie", 
                      :indexes => [@index],
                      :id      => 42)
    @index_record = {:name => "Stewie", :id => 42}
  end

  describe "indexing a new document" do
    before do
      @indexer.create(@document)
    end

    it "inserts a record in to the datastore with the indexed vals and id" do
      @datastore.should have_received(:insert).with(@index, @index_record)
    end
  end

  describe "indexing an existing document" do
    before do
      @indexer.update(@document)
    end

    it "updates the index records in the database" do
      @datastore.should have_received(:update).with(@index, 42, @index_record)
    end
  end
end
