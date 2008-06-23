require File.dirname(__FILE__) + '/helpers/acts_as_rp_helper'

describe OpenidEngine::ActsAsRp do
  include OpenidEngine
  
  before(:each) do
    @rp = OpenidEngine::Rp.new
    @params = {}
    
    @controller = (class SessionController
      include OpenidEngine::ActsAsRp
    end).new
    
    @controller.stub!(:rp).and_return(@rp)
    @controller.stub!(:params).and_return(@params)
  end
  
  def assign_params(params)
    @controller.stub!(:params).and_return(params)
  end
  
  describe "should find openid request" do
    it {
      @controller.openid_request?.should_not be_true
    }
    
    it {
      @params['openid.ns'] = 'hoge'
      @controller.openid_request?.should be_true
    }
    
    it {
      @params['openid_identifier'] = 'hoge'
      @controller.openid_request?.should be_true
    }
  end
  
  describe "#openid_identifier" do
    it "should return normalize url" do
      @params[:openid_identifier] = 'localhost:3000/server'
      @controller.openid_identifier.should == 'http://localhost:3000/server'
    end
  end
end
