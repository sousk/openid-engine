require File.dirname(__FILE__) + '/../spec_helper'
require "openid_engine/rp"
require RAILS_ROOT + '/vendor/plugins/openid_engine/spec/helpers/data'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe SessionsController do
  fixtures :users
  fixtures :openid_associations
  
  describe "OpenidEngine::ActsAsRp" do
    
    before(:each) do
      @identifier = 'http://localhost:3000/'
      @endpoint = 'http://localhost:3000/servers'
      @rp = OpenidEngine::Rp.new({
        :ns => OpenidEngine::TYPE[:ns],
        :assoc_type => 'HMAC-SHA256',
        :session_type => 'DH-SHA256'
      })
      controller.stub!(:rp).and_return(@rp)
    end
    
    describe "#start_openid_authentication" do

      def do_post
        post :create, :openid_identifier => 'http://example.com/user_supplied_id'
      end
      
      def mock_discovery
        @rp.should_receive(:discover_by_yadis).and_return [SERVICE_SERVER]
      end

      it "should do nothing no service found" do
        @rp.should_receive(:discover).and_return []
        controller.should_not_receive(:get_association)
        controller.should_not_receive(:redirect_to)
        do_post
        response.should be_success
      end

      it "should use stored association" do
        mock_discovery
        assoc = openid_associations(:localhost)
        controller.should_receive(:get_association).and_return(assoc)
        do_post
        response.should be_redirect
      end
    end

    
    
    # def post_identifier
    #   post :create, :openid_identifier => @identifier
    # end
    # 
    # def id_res_request
    #   controller.should_receive(:verify_openid_response).and_return(true)
    #   get :show, {
    #     "openid.sig"=>"U6xPgq1u5lmtK45OlmUYwNnU9JdVaXM/4iA3XRL8Rx0=", 
    #     "openid.return_to"=>"http://localhost:8080/session", 
    #     "openid.mode"=>"id_res", 
    #     "openid.claimed_id"=>"http://localhost:3000/servers/jack", 
    #     "openid.op_endpoint"=>"http://localhost:3000/servers", 
    #     "openid.ns"=>"http://specs.openid.net/auth/2.0", 
    #     "openid.response_nonce"=>"2008-05-01T02:35:55ZLF7vs4", 
    #     "action"=>"show", 
    #     "controller"=>"sessions", 
    #     "openid.identity"=>"http://localhost:3000/servers/jack", 
    #     "openid.signed"=>"assoc_handle,claimed_id,identity,mode,ns,op_endpoint,response_nonce,return_to,signed", 
    #     "openid.assoc_handle"=>"{HMAC-SHA256}{4819299f}{imwRIQ==}"
    #   }
    # end
    
    # it "should description" do # TODO: to be removed
      # id_res_request
      
      # res = Object.new
      # res.stub!(:normalized_uri).and_return(XRDSDATA[:uri])
      # res.stub!(:response_text).and_return(XRDSDATA[:doc])
      # OpenID::Yadis.should_receive(:discover).and_return(res)
      
      # @rp.discover_services(@identifier).should == HASHED_XRDS
      # got true
      
      # self.should_receive(:rp).and_return(@rp)
      # @rp.should_receive(:discover_services).with(@identifier).and_return(HASHED_XRDS)
      
      # post_identifier
    # end
  end
  
  # describe "site-base Authentication" do
  #   it 'logins and redirects' do
  #     post :create, :login => 'quentin', :password => 'test'
  #     session[:user_id].should_not be_nil
  #     response.should be_redirect
  #   end
  # 
  #   it 'fails login and does not redirect' do
  #     post :create, :login => 'quentin', :password => 'bad password'
  #     session[:user_id].should be_nil
  #     response.should be_success
  #   end
  # 
  #   it 'logs out' do
  #     login_as :quentin
  #     get :destroy
  #     session[:user_id].should be_nil
  #     response.should be_redirect
  #   end
  # 
  #   it 'remembers me' do
  #     post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
  #     response.cookies["auth_token"].should_not be_nil
  #   end
  # 
  #   it 'does not remember me' do
  #     post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
  #     response.cookies["auth_token"].should be_nil
  #   end
  # 
  #   it 'deletes token on logout' do
  #     login_as :quentin
  #     get :destroy
  #     response.cookies["auth_token"].should == []
  #   end
  # 
  #   it 'logs in with cookie' do
  #     users(:quentin).remember_me
  #     request.cookies["auth_token"] = cookie_for(:quentin)
  #     get :new
  #     controller.send(:logged_in?).should be_true
  #   end
  # 
  #   it 'fails expired cookie login' do
  #     users(:quentin).remember_me
  #     users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
  #     request.cookies["auth_token"] = cookie_for(:quentin)
  #     get :new
  #     controller.send(:logged_in?).should_not be_true
  #   end
  # 
  #   it 'fails cookie login' do
  #     users(:quentin).remember_me
  #     request.cookies["auth_token"] = auth_token('invalid_auth_token')
  #     get :new
  #     controller.send(:logged_in?).should_not be_true
  #   end
  # 
  #   def auth_token(token)
  #     CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  #   end
  # 
  #   def cookie_for(user)
  #     auth_token users(user).remember_token
  #   end
  # end
  
end
