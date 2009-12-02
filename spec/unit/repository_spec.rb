require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Repository" do
  before do
    @doc        = stub(:to_hash    => {:name => "Stewie"}, 
                       :table_name => "users",
                       :id=        => nil)

    @json       = "THE JSONS"
    @serializer = stub
    @serializer.stubs(:generate).with({:name => "Stewie"}).returns(@json)
    @id         = 5
    @dataset    = stub(:insert   => @id)
    @database   = stub
    @database.stubs(:from).with("users").returns(@dataset)
    @repository = Friendly::Repository.new(@database, @serializer)
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

  describe "finding an object by id" do
    before do
      @parsed_hash = {:name => "Stewie"}
      @serializer.stubs(:parse).returns(@parsed_hash)
      @dataset.stubs(:first).returns(@json)
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
      @klass.should have_received(:new).with(@parsed_hash)
    end

    it "returns the document" do
      @returned_doc.should == @doc
    end
  end
end
