require File.dirname(__FILE__) + '/helpers/op_helper'
require File.dirname(__FILE__) + '/helpers/message_helper'
require "openid_engine/associatable"

describe OpenidEngine::Associatable do
  before(:all) do
    OpenidAssociation.class_eval("include OpenidEngine::Associatable")
  end
  
  before(:each) do
    mock_rails_controller
    mock_agent
    
    @op_endpoint = 'http://op_endpoint.example.com/'
  end
  
  it {
    OpenidAssociation.should be_include(OpenidEngine::Associatable)
    OpenidAssociation.should respond_to(:request)
  }
  
  it "should request association to op and init it" do
    response = mocked_message('assoc_response')
    OpenidAssociation.should_receive(:request_to_op).and_return response
    
    mocked_dh = mock_dh
    mock_dh.should_receive(:extract_enc_mac_key)
    
    OpenidAssociation.should_receive(:new_from_response).with(@op_endpoint, response)
    OpenidAssociation.request @op_endpoint
  end
  
  #   before(:each) do
  #     @rp_dh_object = mock_dh
  # 
  #     @response = {
  #       :assoc_handle => '{HMAC-SHA256}{48112eb6}{ZjnVgQ==}',
  #       :assoc_type => 'HMAC-SHA256',
  #       :dh_server_public => "dh.public_key",
  #       :enc_mac_key => 'hoge',
  #       :expires_in => '1209600',
  #       :ns => 'http://specs.openid.net/auth/2.0',
  #       :session_type => 'DH-SHA256'
  #     }
  #   end
  #   
  #   it {
  #     @association.should_receive(:request_to_op).and_return @response
  #     @rp_dh_object.should_receive(:extract_enc_mac_key)
  #     @repos.should_receive('<<')
  #     @association.request @op_endpoint, mod, gen
  #   }
  # end
  
end
