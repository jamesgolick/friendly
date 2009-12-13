require File.expand_path("../../spec_helper", __FILE__)

describe "Finding objects in the cache" do
  def cache_key(user)
    ["Address", user.id.to_guid].join("/")
  end

  describe "by id" do
    before do
      @address = Address.create :street => "Spooner"
    end

    describe "if the user is in cache" do
      before do
        $cache.set(cache_key(@address), "the address")
      end

      it "returns the object from cache if its there" do
        Address.first(:id => @address.id).should == "the address"
      end
    end

    describe "if the user isn't there" do
      before do
        $cache.delete(cache_key(@address))
        @found = Address.first(:id => @address.id)
      end

      it "finds the object in the database" do
        @found.should == @address
      end

      it "stores the object in cache (read through)" do
        $cache.get(cache_key(@address)).should == @address
      end
    end
  end

  describe "several objects via id" do
    before do
      @addresses = (0..3).map { Address.create :street => "Spooner" }
    end

    describe "when all objects are found" do
      before do
        @addresses.each { |a| $cache.set(cache_key(a), "the address") }
      end

      it "returns all the objects from cache" do
        Address.all(:id => @addresses.map { |u| u.id }).should == ["the address"] * 4
      end
    end

    describe "when some objects are missing" do
      before do
        $cache.delete(cache_key(@addresses.first))
        @found = Address.all(:id => @addresses.map { |u| u.id })
      end

      it "finds the object and returns it" do
        expected = @addresses.sort { |a,b| a.id <=> b.id }
        @found.sort { |a,b| a.id <=> b.id }.should == expected
      end

      it "writes the object through to the cache" do
        lambda {
          $cache.get(cache_key(@addresses.first))
        }.should_not raise_error
      end
    end
  end
end
