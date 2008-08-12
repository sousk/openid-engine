require File.dirname(__FILE__) + '/../spec_helper'
require "openid_engine/message/association_request"

describe OpenidEngine::Message::AssociationRequest do
  include OpenidEngine
  
  def get_request(params={})
    OpenidEngine::Message::AssociationRequest.new params
  end
  
  def valid_params
    {
      :assoc_handle => 'hoge',
      :assoc_type => 'HMAC-SHA1',
      :session_type => 'no-encryption',
      :mac_key => '1',
      :expires_in => '1'
    }
  end
  
  def dh_params
    @dh = mock_dh
    valid_params.merge({
      :session_type => 'DH-SHA256',
      :dh_modulus => @dh.mod,
      :dh_gen => @dh.gen,
      :dh_consumer_public => @dh.public_key
    })
  end
  
  it "should have validation rules" do
    msg = get_request valid_params
    msg.rules.size.should >= 2
    msg.requires.size.should >= 2
  end
  
  describe "with Diffie-Hellman request parameters" do
    before(:each) do
      @msg = get_request dh_params
    end
    
    it "should have extra rules" do
      @msg.requires.size.should >= 5
    end
    
    it "should be valid" do
      @msg.valid?.should be_true
    end
    
    it "should not be valid when parameters missing" do
      params = dh_params
      [:dh_modulus, :dh_modulus, :dh_gen].each { |dh_param|
        get_request(
          params.reject {|k,v| k == dh_param}
        ).valid?.should_not be_true
      }
    end
  end
    
  describe "#init_from_raw" do
    it "should encode params" do
      msg = OpenidEngine::Message::AssociationRequest.init_from_raw dh_params
      msg[:dh_gen].should == encode_integer(dh_params[:dh_gen])
    end
  end
  
  describe "#valid?" do
    it "should return true with valid params" do
      msg = get_request valid_params
      msg.valid?.should be_true
    end

    it "should return false with invalid params" do
      msg = get_request
      msg.valid?.should_not be_true
    end
  end
end
