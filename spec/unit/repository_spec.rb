require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Repository" do
  before do
    @doc        = stub(:to_hash     => {:name       => "Stewie",
                                        :id         => nil,
                                        :created_at => nil,
                                        :updated_at => nil}, 
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

    it "only serializes the attributes that aren't reserved" do
      @serializer.should have_received(:generate).with({:name => "Stewie"})
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

  describe "finding a non-existant object by id" do
    before do
      Friendly.config.repository = @repository
      @dataset.stubs(:first).returns(nil)
    end

    it "raises Friendly::RecordNotFound" do
      lambda { User.find(1) }.should raise_error(Friendly::RecordNotFound)
    end
  end

  describe "finding multiple objects by id" do
    before do
      @obj   = stub
      @klass = stub(:new => @obj, :table_name => "users", :name => "User")
    end

    describe "when all the objects are found" do
      before do
        @serializer.stubs(:parse).returns({})
        @dataset.stubs(:where).returns([{:id => 1, :attributes => "{}"}, 
                                        {:id => 2, :attributes => "{}"}])
        @return = @repository.find(@klass, 1,2)
      end

      it "returns objects of klass" do
        @klass.should have_received(:new).with(:id         => 1, 
                                               :created_at => nil, 
                                               :updated_at => nil)
        @klass.should have_received(:new).with(:id         => 2,
                                               :created_at => nil,
                                               :updated_at => nil)
        @return.should == [@obj, @obj]
      end

      it "deserializes the attributes" do
        @serializer.should have_received(:parse).with("{}").twice
      end
    end
    
    describe "when no objects are found" do
      before do
        @dataset.stubs(:where).returns([])
      end

      it "raises record not found" do
        lambda {
          @repository.find(@klass, 1, 2, 3) 
        }.should raise_error(Friendly::RecordNotFound)
      end
    end
  end
end
