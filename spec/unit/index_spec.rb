require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Index" do
  before do
    @klass = stub(:table_name => "users")
  end

  describe "with one field" do
    before do
      @index = Friendly::Index.new(@klass, [:name])
    end

    it "has an appropriate table name" do
      @index.table_name.should == "index_users_on_name"
    end
  end

  describe "with multiple fields" do
    before do
      @index = Friendly::Index.new(@klass, [:name, :age])
    end

    it "has an appropriate table name" do
      @index.table_name.should == "index_users_on_name_and_age"
    end
  end
end
