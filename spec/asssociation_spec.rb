require File.dirname(__FILE__) + '/helpers/op_helper'
require "openid_engine/association"

describe OpenidEngine::Association do
  before(:each) do
    mock_rails_controller
    @repos = OpenidAssociation.new
    @association = OpenidEngine::Association.new @repos
    @assoc = mock('assoc')
    @op_endpoint = 'http://op_endpoint.example.com/'
  end
  
  it "should retrieve stored association by op_endpoint" do
    @repos.should_receive(:find).with(:first, {:op_endpoint => @op_endpoint}).and_return(@assoc)
    @association.find(:op_endpoint => @op_endpoint).should == @assoc
  end
  
  it "should retrieve stored association by assoc_handle" do
    handle = 'handle'
    @repos.should_receive(:find).with(:first, {:handle => handle}).and_return(@assoc)
    @association.find(:handle => handle).should == @assoc
  end
  
  it "should send request to op for association" do
    @association.request(@op_endpoint).should == @assoc
  end
  
  it "should store association"
end
