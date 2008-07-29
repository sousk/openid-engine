require File.dirname(__FILE__) + '/../spec_helper'
require "openid_engine/message/associate"

describe OpenidEngine::Message::AssociateRequest do
  include OpenidEngine
  
  def get_response(params={})
    OpenidEngine::Message.factory :associate_response, params
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
  
  it "should have validation rules" do
    msg = get_response valid_params
    msg.rules.size.should >= 2
    msg.requires.size.should >= 2
  end
  
  describe "#valid?" do
    it "should return true with valid params" do
      msg = get_response valid_params
      msg.valid?.should be_true
    end

    it "should return false with invalid params" do
      msg = get_response
      msg.valid?.should_not be_true
    end
  end
end
