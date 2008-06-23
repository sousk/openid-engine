require File.dirname(__FILE__) + '/../openid_helper'

require 'openid_engine/rp'

module OpenidHelper
  include OpenidEngine
    
  def do_assoc_request(path)
    post path
  end
  
  private
  def policy
    {
      :ns =>'http://specs.openid.net/auth/2.0',
      :assoc_type => 'HMAC-SHA256',
      :session_type => 'DH-SHA256'
    }
  end
  
  def agent
    @agent ||= Agent.new
  end
  
  def associator
    @associator ||= Associator.factory(policy, agent, [Rp.const_get(:DEFAULT_DH_MODULUS), Rp.const_get(:DEFAULT_DH_GEN)])
  end
end


describe ServersController do
  include OpenidHelper
  fixtures :openid_associations
  
  # describe "POST /server" do
  #   it "should accept OpenID Association Request" do
  #     associator
  #     rp_private = associator.gen_private_key
  #     rp_public = associator.gen_public_key(rp_private)
  #     
  #     secret = Base64.decode64 "FOwbMI7CxUqcNmW6LUB93MuTQeS8sfTi40eoSl8BUYQ="
  #     controller.stub!(:gen_secret).and_return(secret)
  #     controller.stub!(:gen_private_key).and_return(5488405432878174843808638163700734694216517720632120820928439521151449002346793799560151135964209333118631589047091073186152179545686926415733601376069400286547769137874754526466599824857115283872670595460688498619072962780578231384825750944583246762830472014568034241484701832424013374988315920544700921441)
  #     
  #     query = {}
  #     associator.make_query(policy, rp_public).each { |k,v| query["openid.#{k}"] = v }
  #     
  #     post :create, query
  #     
  #     res = @agent.direct_response_to_hash(response.body)
  #     extracted_secret = associator.extract_secret_1(res, rp_private, associator.mod)
  #     extracted_secret.should == secret
  #     
  #     # sec2 = Base64.decode64
  #     # puts "secret::#{Base64.encode64(sec2)}"
  #   end
  # end
  
  def mock_server_association
    @assoc = openid_associations(:sha256)
    @secret = Base64.decode64 "FOwbMI7CxUqcNmW6LUB93MuTQeS8sfTi40eoSl8BUYQ="
    @server_private = 5488405432878174843808638163700734694216517720632120820928439521151449002346793799560151135964209333118631589047091073186152179545686926415733601376069400286547769137874754526466599824857115283872670595460688498619072962780578231384825750944583246762830472014568034241484701832424013374988315920544700921441
    controller.stub!(:gen_secret).and_return(@secret)
    controller.stub!(:gen_private_key).and_return(@server_private)
  end
  
  describe "GET /server" do
    
    it "should accept OpenID Authentication Request" do
      
      mock_server_association
      param = {
        'openid.ns' => 'http://specs.openid.net/auth/2.0',
        'openid.mode' => 'checkid_setup',
        'openid.identity' => 'http://specs.openid.net/auth/2.0/identifier_select',
        'openid.claimed_id' => 'http://specs.openid.net/auth/2.0/identifier_select',
        'openid.return_to' => 'http://localhost:8080/session/',
        'openid.realm' => 'http://localhost:8080/session/',
        'openid.assoc_handle' => @assoc[:handle]
      }
      
      get :show, param
      
      response.should be_redirect
      puts response.body
    end
  end
  
  
  
  # describe "GET /server" do
  #   
  #   it "should return XRDS document with application/xrds+xml accept-type" do
  #     # do_get_with_xrds :show
  #     get :show
  #     response.should be_success
  #     response.should render_template('servers/xrds.xml.erb')
  #   end
  #   
  # end
  # 
  # describe "GET /server/xrds" do
  #   it "should return XRDS document" do
  #     get :xrds
  #     response.should be_success
  #     response.should render_template('servers/xrds.xml.erb')
  #   end
  # end


end
