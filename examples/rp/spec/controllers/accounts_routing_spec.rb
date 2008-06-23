require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController do
  describe "route generation" do

    it "should map { :controller => 'accounts', :action => 'index' } to /accounts" do
      route_for(:controller => "accounts", :action => "index").should == "/accounts"
    end
  
    it "should map { :controller => 'accounts', :action => 'new' } to /accounts/new" do
      route_for(:controller => "accounts", :action => "new").should == "/accounts/new"
    end
  
    it "should map { :controller => 'accounts', :action => 'show', :id => 1 } to /accounts/1" do
      route_for(:controller => "accounts", :action => "show", :id => 1).should == "/accounts/1"
    end
  
    it "should map { :controller => 'accounts', :action => 'edit', :id => 1 } to /accounts/1/edit" do
      route_for(:controller => "accounts", :action => "edit", :id => 1).should == "/accounts/1/edit"
    end
  
    it "should map { :controller => 'accounts', :action => 'update', :id => 1} to /accounts/1" do
      route_for(:controller => "accounts", :action => "update", :id => 1).should == "/accounts/1"
    end
  
    it "should map { :controller => 'accounts', :action => 'destroy', :id => 1} to /accounts/1" do
      route_for(:controller => "accounts", :action => "destroy", :id => 1).should == "/accounts/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'accounts', action => 'index' } from GET /accounts" do
      params_from(:get, "/accounts").should == {:controller => "accounts", :action => "index"}
    end
  
    it "should generate params { :controller => 'accounts', action => 'new' } from GET /accounts/new" do
      params_from(:get, "/accounts/new").should == {:controller => "accounts", :action => "new"}
    end
  
    it "should generate params { :controller => 'accounts', action => 'create' } from POST /accounts" do
      params_from(:post, "/accounts").should == {:controller => "accounts", :action => "create"}
    end
  
    it "should generate params { :controller => 'accounts', action => 'show', id => '1' } from GET /accounts/1" do
      params_from(:get, "/accounts/1").should == {:controller => "accounts", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'accounts', action => 'edit', id => '1' } from GET /accounts/1;edit" do
      params_from(:get, "/accounts/1/edit").should == {:controller => "accounts", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'accounts', action => 'update', id => '1' } from PUT /accounts/1" do
      params_from(:put, "/accounts/1").should == {:controller => "accounts", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'accounts', action => 'destroy', id => '1' } from DELETE /accounts/1" do
      params_from(:delete, "/accounts/1").should == {:controller => "accounts", :action => "destroy", :id => "1"}
    end
  end
end