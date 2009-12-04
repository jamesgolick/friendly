require File.expand_path("../../spec_helper", __FILE__)
require 'ostruct'

describe "Friendly::Translator" do
  before do
    @serializer = stub
    @translator = Friendly::Translator.new(@serializer)
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
end
