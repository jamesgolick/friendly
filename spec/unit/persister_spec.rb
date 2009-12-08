require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Persister" do
  before do
    @document_hash = {:name => "whatever"}
    @indexes       = stub(:create => nil, :update => nil)
    @document      = FakeDocument.new :table_name => "users",
                                      :to_hash    => @document_hash,
                                      :indexes    => @indexes
    @datastore     = DataStoreFake.new  :insert   => 42
    @translator    = stub
    @persister     = Friendly::Persister.new(@datastore, @translator)
    @record = {:created_at => Time.new, :updated_at => Time.new}
    @translator.stubs(:to_record).with(@document).returns(@record)
  end

  describe "saving a new_record?" do
    before do
      @document.new_record = true
      @persister.save(@document)
    end

    it "saves the record from the translator to the database" do
      @datastore.inserts.should include([@document, @record])
    end

    it "sets the id on the document" do
      @document.id.should == 42
    end

    it "sets the created_at on the document" do
      @document.created_at.should == @record[:created_at]
    end

    it "sets the updated_at on the document" do
      @document.updated_at.should == @record[:updated_at]
    end

    it "asks the index set to create the indexes" do
      @document.indexes.should have_received(:create).with(@document)
    end
  end

  describe "updating a record" do
    before do
      @document.id         = 24
      @document.new_record = false
      @persister.save(@document)
    end

    it "saves the record from the translator" do
      @datastore.updates.should include([@document, 24, @record])
    end
    
    it "sets the created_at from the translator" do
      @document.created_at.should == @record[:created_at]
    end

    it "sets the updated_at from the translator" do
      @document.updated_at.should == @record[:updated_at]
    end

    it "asks the index set to update the indexes" do
      @document.indexes.should have_received(:update).with(@document)
    end
  end
end
