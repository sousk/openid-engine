require File.dirname(__FILE__) + '/../helpers/op_helper'
require "openid_engine/message/checkid_request"


describe OpenidEngine::Message::CheckidRequest do
  include OpenidEngine
  
  def get_request_message(params={})
    OpenidEngine::Message.factory :checkid_request, params
  end
  
  def valid_params
    {
      :claimed_id => 'http://example.com/claimed_id',
      :identity => 'http://example.com/identity',
      :return_to => 'http://example.com/return_to',
      :assoc_handle => '1'
    }
  end
  
  describe ":realm" do
    before(:each) do
      @return_to = 'http://example.com/return_to'
    end
    
    it "should have default value same as return_to" do
      msg = get_request_message :return_to => @return_to
      msg.should have_key(:realm)
      msg[:realm].should == @return_to
    end

    it "should be override with assigned value" do
      realm = 'http://example.com/'
      msg = get_request_message :return_to => @return_to, :realm => realm
      msg[:realm].should == realm
    end
  end
    
  describe "validation" do
    it "should have rules on initialize" do
      msg = get_request_message
      msg.rules.size.should >= 1
      msg.requires.size.should >= 4
    end

    it "should require realm when return_to is omitted" do
      msg = get_request_message
      msg.requires.should be_include(:realm)
      
      msg = get_request_message :return_to => 'http://localhost:8080/'
      msg.requires.should_not be_include(:realm)
    end
    
  end
  
  describe "#valid?" do
    it "should return true with valid params" do
      msg = get_request_message valid_params
      msg.valid?.should be_true
    end

    it "should return false with invalid params" do
      msg = get_request_message valid_params.reject{|k,v| k == :return_to}
      msg.valid?.should_not be_true
    end
  end
end
