require File.expand_path("../../spec_helper", __FILE__)
require 'ostruct'

describe "Friendly::Translator" do
  before do
    @serializer = stub
    @time       = stub
    @translator = Friendly::Translator.new(@serializer, @time)
  end

  describe "translating a row to an object" do
    before do
      @serializer.stubs(:parse).with("THE JSON").returns(:name => "Stewie")
      @time  = Time.new
      @row   = {:id         => 1,
                :created_at => @time,
                :updated_at => @time,
                :attributes => "THE JSON"}
      @klass = FakeDocument
      @doc   = @translator.to_object(@klass, @row)
    end

    it "creates a klass with the attributes from the json" do
      @doc.name.should == "Stewie"
    end

    it "adds the attributes from the table" do
      @doc.id.should         == 1
      @doc.created_at.should == @time
      @doc.updated_at.should == @time
    end
  end

  describe "translating from a document in to a record" do
    describe "when the document has yet to be saved" do
      before do
        @hash = {:name => "Stewie"}
        @time.stubs(:new).returns(Time.new)
        @serializer.stubs(:generate).with(@hash).returns("SOME JSON")
        @document = stub(:to_hash     => @hash, 
                         :new_record? => true, 
                         :created_at  => nil)
        @record = @translator.to_record(@document)
      end

      it "serializes the attributes" do
        @record[:attributes].should == "SOME JSON"
      end

      it "sets a created_at" do
        @record[:created_at].should == @time.new
      end

      it "sets updated_at" do
        @record[:updated_at].should == @time.new
      end
    end

    describe "when the document has already been saved" do
      before do
        @created_at = Time.new
        @hash = {:name       => "Stewie",
                 :id         => 1,
                 :created_at => @created_at,
                 :updated_at => Time.new}
        @time.stubs(:new).returns(Time.new + 5000)
        @serializer.stubs(:generate).returns("SOME JSON")
        @document = stub(:to_hash     => @hash, 
                         :created_at  => @created_at,
                         :new_record? => false)
        @record = @translator.to_record(@document)
      end

      it "serializes the attributes" do
        @serializer.should have_received(:generate).with(:name => "Stewie")
        @record[:attributes].should == "SOME JSON"
      end

      it "doesn't bump the created_at" do
        @record[:created_at].should == @created_at
      end

      it "should bump the updated_at" do
        @record[:updated_at].should == @time.new
      end
    end
  end
end
