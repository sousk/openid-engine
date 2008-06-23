# require File.dirname(__FILE__) + '/spec_helper'
# require "openid_engine/association"
# 
# describe OpenidEngine::Association do
#   BTWOC_EXAMPLE = [
#     [0, "\x00"], 
#     [127, "\x7F"],
#     [128, "\x00\x80"], 
#     [255, "\x00\xFF"], 
#     [32768, "\x00\x80\x00"], 
#   ]
#   
#   POLICY = {
#     :ns => OpenidEngine::TYPE_URI[:auth2p0],
#     :mode => 'associate',
#     :assoc_type => 'HMAC-SHA256',
#     :session_type => 'DH-SHA256',
#     :identity => 'http://localhost:3000/users/sou',
#     :return_to => 'http://localhost:8080/session', 
#     :dh_modulus => 'todo',
#     :dh_gen => 'todo',
#     :dh_consumer_public => 'todo'
#   }
#   
#   before(:each) do
#     @assoc = OpenidEngine::RpAssociation.new(POLICY)
#   end
#   
#   it "should encode to btwoc" do
#     BTWOC_EXAMPLE.each { |num, encoded| num.to_btwoc.should == encoded }
#   end
#   
#   it "should decode btwoc" do
#     BTWOC_EXAMPLE.each { |decoded, encoded| @assoc.class.btwoc_decode(encoded).should == decoded }
#   end
#   
#   it "should validate request parameter" 
#   # do
#   #   lambda {
#   #     @assoc.validate
#   #   }.should_not raise_error
#   # end
#   
#   it "should raise error when invalid parameter passed" do
#     p = POLICY.dup
#     p[:mode] = 'checkid_setup'
#     assoc = OpenidEngine::RpAssociation.new(p)
#     lambda {
#       assoc.validate
#     }.should raise_error
#   end
#   
#   it do
#     puts @assoc.request
#   end
# end
