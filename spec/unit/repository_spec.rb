require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Repository" do
  before do
    @doc        = stub(:to_hash     => {:name => "Stewie"}, 
                       :table_name  => "users",
                       :id=         => nil,
                       :created_at= => nil,
                       :updated_at= => nil,
                       :new_record? => true,
                       :id          => nil)

    @json       = "THE JSONS"
    @serializer = stub
    @serializer.stubs(:generate).with({:name => "Stewie"}).returns(@json)
    @id         = 5
    @dataset    = stub(:insert   => @id)
    @database   = stub
    @database.stubs(:from).with("users").returns(@dataset)
    @time       = Time.new
    @time_stub  = stub(:new => @time)
    @repository = Friendly::Repository.new(@database, @serializer, @time_stub)
  end

  describe "saving a new object" do
    before do
      @repository.save(@doc)
    end

    it "knows how to save objects" do
      @dataset.should have_received(:insert).with(:attributes => "THE JSONS",
                                                  :created_at => @time,
                                                  :updated_at => @time)
    end

    it "sets the id of the document" do
      @doc.should have_received(:id=).with(@id)
    end

    it "sets the created_at of the document" do
      @doc.should have_received(:created_at=).with(@time)
    end

    it "sets the updated_at of the document" do
      @doc.should have_received(:updated_at=).with(@time)
    end
  end

  describe "saving an existing object" do
    before do
      @filter = stub(:update => nil)
      @dataset.stubs(:where).with(:id => 42).returns(@filter)
      @doc.stubs(:new_record?).returns(false)
      @doc.stubs(:id).returns(42)
      @repository.save(@doc)
    end

    it "updates the object in the database" do
      @filter.should have_received(:update).with(:updated_at => @time,
                                                 :attributes => "THE JSONS")
    end

    it "sets the updated_at on the doc" do
      @doc.should have_received(:updated_at=).with(@time)
    end

    it "doesn't set the id on the row" do
      @doc.should_not have_received(:id=)
    end

    it "doesn't set the created_at on the row" do
      @doc.should_not have_received(:created_at=)
    end
  end

  describe "finding an object by id" do
    before do
      @parsed_hash = {:name => "Stewie"}
      @serializer.stubs(:parse).returns(@parsed_hash)
      @dataset.stubs(:first).returns(:attributes => @json, 
                                     :id         => 1, 
                                     :created_at => @time,
                                     :updated_at => @time)
      @klass = stub(:table_name => "users", :new => @doc)
      @returned_doc = @repository.find(@klass, 1)
    end

    it "finds in the table" do
      @dataset.should have_received(:first).with(:id => 1)
    end

    it "uses the serializer to parse the json" do
      @serializer.should have_received(:parse).with(@json)
    end

    it "instantiates an object of type @klass with the resulting hash" do
      extra_attrs = {:id => 1, :created_at => @time, :updated_at => @time}
      @klass.should have_received(:new).with(@parsed_hash.merge(extra_attrs))
    end

    it "returns the document" do
      @returned_doc.should == @doc
    end
  end
end
