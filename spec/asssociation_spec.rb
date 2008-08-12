# require File.dirname(__FILE__) + '/helpers/op_helper'
# require "openid_engine/association"
# 
# describe OpenidEngine::Association do
#   before(:each) do
#     mock_rails_controller
#     mock_agent
#     
#     @repos = OpenidAssociation
#     @association = OpenidEngine::Association.new @repos
#     @assoc = mock('assoc')
#     @op_endpoint = 'http://op_endpoint.example.com/'
#   end
# 
#   it "should retrieve stored association by op_endpoint" do
#     @repos.should_receive(:find).with(:first, {:op_endpoint => @op_endpoint}).and_return(@assoc)
#     @association.find(:op_endpoint => @op_endpoint).should == @assoc
#   end
#   
#   it "should retrieve stored association by assoc_handle" do
#     handle = 'handle'
#     @repos.should_receive(:find).with(:first, {:handle => handle}).and_return(@assoc)
#     @association.find(:handle => handle).should == @assoc
#   end
#   
#   describe "#request" do
#     before(:each) do
#       @rp_dh_object = mock_dh
# 
#       @response = {
#         :assoc_handle => '{HMAC-SHA256}{48112eb6}{ZjnVgQ==}',
#         :assoc_type => 'HMAC-SHA256',
#         :dh_server_public => "dh.public_key",
#         :enc_mac_key => 'hoge',
#         :expires_in => '1209600',
#         :ns => 'http://specs.openid.net/auth/2.0',
#         :session_type => 'DH-SHA256'
#       }
#     end
#     
#     it {
#       @association.should_receive(:request_to_op).and_return @response
#       @rp_dh_object.should_receive(:extract_enc_mac_key)
#       @repos.should_receive('<<')
#       @association.request @op_endpoint, mod, gen
#     }
#   end
#   
# end
