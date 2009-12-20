require File.expand_path("../../../spec_helper", __FILE__)

describe "Friendly::Associations::Association" do
  before do
    @owner_klass = stub
    @klass       = stub
    # FIXME: ugh.
    String.any_instance.stubs(:constantize).returns(@klass)
    association  = Friendly::Associations::Association
    @association = association.new(@owner_klass, :addresses)
  end

  it "has a default klass of name.classify.constantize" do
    @association.klass.should == @klass
  end

  it "has a foreign_key of name.singularize + '_id'" do
    @association.foreign_key.should == :address_id
  end

  it "returns a scope on klass of {:foreign_key => document.id}" do
    @scope = stub
    @klass.stubs(:scope).with(:address_id => 42).returns(@scope)

    @association.scope(stub(:id => 42)).should == @scope
  end
end
