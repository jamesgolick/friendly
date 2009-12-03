require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Persister" do
  before do
    @document_hash = {:name => "whatever"}
    @document      = FakeDocument.new :table_name => "users",
                                      :to_hash    => @document_hash
    @datastore     = DataStoreFake.new  :insert   => 42
    @serializer    = SerializerFake.new :generate => {
                                           @document_hash => "THE JSON"
                                        }
    @time          = TimeFake.new Time.new
    @persister     = Friendly::Persister.new(@datastore, @serializer, @time)
  end

  describe "saving a new_record?" do
    before do
      @document.new_record = true
      @persister.save(@document)
    end

    it "saves the serialized and table attributes to the database" do
      cols  = {:attributes => "THE JSON",
               :created_at => @time.new,
               :updated_at => @time.new}
      @datastore.inserts.should include([@document, cols])
    end

    it "sets the id on the document" do
      @document.id.should == 42
    end

    it "sets the created_at on the document" do
      @document.created_at.should == @time.new
    end

    it "sets the updated_at on the document" do
      @document.updated_at.should == @time.new
    end
  end

  describe "updating a record" do
    before do
      @hash     = {
        :id         => 24,
        :created_at => @time.new - 5000,
        :updated_at => @time.new - 5000,
        :name       => "whatever"
      }
      @document = FakeDocument.new :new_record => false,
                                   :to_hash    => @hash,
                                   :id         => 24,
                                   :created_at => @time.new - 5000
      @persister.save(@document)
    end

    it "updates the record in the datastore with serialized and non-table fields" do
      @datastore.updates.length.should == 1
      cols = {:attributes => "THE JSON",
              :created_at => @hash[:created_at],
              :updated_at => @time.new}
      @datastore.updates.should include([@document, 24, cols])
    end
    
    it "doesn't clobber the created_at" do
      @document.created_at.should == @hash[:created_at]
    end

    it "sets the updated_at" do
      @document.updated_at.should == @time.new
    end
  end
end
