require File.expand_path("../../spec_helper", __FILE__)

describe "Building an index offline" do
  before do
    $db.drop_table :awesome_things if $db.table_exists?(:awesome_things)

    if $db.table_exists?(:index_awesome_things_on_name)
      $db.drop_table :index_awesome_things_on_name
    end

    @klass = Class.new do
      def self.name; "AwesomeThing"; end
      def self.table_name; "awesome_things"; end

      include Friendly::Document

      attribute :name, String
    end
    @klass.create_tables!

    @jameses = [@klass.create(:name => "James"), @klass.create(:name => "James")]

    @klass.indexes :name
    @klass.create_tables!
  end

  describe "" do
    before do
      Friendly::Indexer.populate(@klass, :name)
    end

    it "builds the missing index rows for all the rows in the doc table" do
      @klass.all(:name => "James").should == @jameses
    end

    it "ignores records that are already in the index" do
      lambda {
        Friendly::Indexer.populate(@klass, :name)
      }.should_not raise_error
    end
  end

  describe "with more than `Indexer.objects_per_iteration` objects" do
    before do
      Friendly::Indexer.objects_per_iteration = 1
      Friendly::Indexer.populate(@klass, :name)
    end

    it "builds the missing index rows for all the rows in the doc table" do
      @klass.all(:name => "James").should == @jameses
    end
  end
end
