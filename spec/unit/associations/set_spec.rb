require File.expand_path("../../../spec_helper", __FILE__)

describe "Friendly::Associations::Set" do
  before do
    @klass             = stub
    @association_klass = stub
    @set               = Friendly::Associations::Set.new(@klass, @association_klass)
    @assoc             = stub
    @association_klass.stubs(:new).
      with(@klass, :my_awesome_association).returns(@assoc)
  end

  describe "adding an association" do
    before do
      @set.add(:my_awesome_association)
    end

    it "creates an association and adds it to its hash by name" do
      @set.associations[:my_awesome_association].should == @assoc
    end
  end

  it "can return the association by name" do
    @set.add(:my_awesome_association)
    @set.get(:my_awesome_association).should == @assoc
  end

  it "provides the scope for an association by name" do
    @scope = stub
    @assoc.stubs(:scope).returns(@scope)
    @set.add(:my_awesome_association)
    @set.get_scope(:my_awesome_association).should == @scope
  end
end
