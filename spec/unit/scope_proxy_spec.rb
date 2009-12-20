require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::ScopeProxy" do
  before do
    @klass             = Class.new
    @scope             = stub
    @scope_klass       = stub
    @scope_proxy       = Friendly::ScopeProxy.new(@klass, @scope_klass)
    @params            = {:order! => :created_at.desc}
    @scope_klass.stubs(:new).with(@klass, @params).returns(@scope)
    @klass.stubs(:scope_proxy).returns(@scope_proxy)
    @scope_proxy.add_named(:recent, @params)
  end

  describe "adding a scope" do
    it "adds a scope by that name to the set" do
      @scope_proxy.get(:recent).should == @params
    end

    it "adds a method to the klass that returns an instance of the scope" do
      @klass.recent.should == @scope
    end
  end

  describe "getting an instance of a scope" do
    it "instantiates Scope" do
      @scope_proxy.get_instance(:recent).should == @scope
    end
  end

  describe "accessing an ad_hoc scope" do
    it "instantiates Scope" do
      @scope_proxy.ad_hoc(@params).should == @scope
    end
  end
end
