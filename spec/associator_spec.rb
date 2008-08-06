require File.dirname(__FILE__) + '/helpers/rp_helper'

describe OpenidEngine::DiffieHellmanAssociator do
  
  before(:each) do
    @op_endpoint = 'http://localhost:3000/servers'
    @agent = OpenidEngine::Agent.new
    @mod = 155172898181473697471232257763715539915724801966915404479707795314057629378541917580651227423698188993727816152646631438561595825688188889951272158842675419950341258706556549803580104870537681476726513255747040765857479291291572334510643245094715007229621094194349783925984760375594985848253359305585439638443
    @gen = 2
    @associator = OpenidEngine::DiffieHellmanAssociator.new(
      @agent,
      [@mod, @gen]
    )
  end
  
  describe "#associate" do
    before(:each) do
      @agent.should_receive(:direct).and_return({
        :assoc_handle => '{HMAC-SHA256}{48112eb6}{ZjnVgQ==}',
        :assoc_type => 'HMAC-SHA256',
        :dh_server_public => 'FrHWmH/h0E42YFFwmBY8D5yGEpd6vWuRXh4UxEM1TRmkk7hyyS166jF20yylzSUmjozR/UrH7viMobliwOaZv6AnGOHj79tCXjC64z9HhUQOb0+6j1J7z7Bk5Sg7Ea7cyrRT7I+JIn7MGQmBhjezWA7fU3ESVzJ/uNv7pksw9IA=',
        :enc_mac_key => '84sVeyeqscGEbOWOhmZphWuUILn8IUTSUv0POxkE8fw=',
        :expires_in => '1209600',
        :ns => 'http://specs.openid.net/auth/2.0',
        :session_type => 'DH-SHA256'
      })
      @associate = @associator.associate @op_endpoint
    end
    it "should description" do
      @associate.should_not be_empty
    end
  end

  
  # it {
  #   policy = {
  #     :ns => OpenidEngine::TYPE[:auth2p0],
  #     :assoc_type => 'HMAC-SHA256',
  #     :session_type => 'DH-SHA256'
  #   }
    # OpenidEngine::Agent.should_receive(:direct).and_return({
    #   :assoc_handle => '{HMAC-SHA256}{48112eb6}{ZjnVgQ==}',
    #   :assoc_type => 'HMAC-SHA256',
    #   :dh_server_public => 'FrHWmH/h0E42YFFwmBY8D5yGEpd6vWuRXh4UxEM1TRmkk7hyyS166jF20yylzSUmjozR/UrH7viMobliwOaZv6AnGOHj79tCXjC64z9HhUQOb0+6j1J7z7Bk5Sg7Ea7cyrRT7I+JIn7MGQmBhjezWA7fU3ESVzJ/uNv7pksw9IA=',
    #   :enc_mac_key => '84sVeyeqscGEbOWOhmZphWuUILn8IUTSUv0POxkE8fw=',
    #   :expires_in => '1209600',
    #   :ns => 'http://specs.openid.net/auth/2.0',
    #   :session_type => 'DH-SHA256'
    # })
  #   manager = OpenidEngine::Associator.factory(policy, @agent, [@mod, @gen])
  #   assoc = manager.associate @op_endpoint
  #   # asm.associate('http://www.myopenid.com/server')
  #   
  #   # Requesting Authentication
  #   request_checkid_setup(assoc)
  # }
  
  # def request_checkid_setup(assoc)
  #   param = {
  #     :ns => 'http://specs.openid.net/auth/2.0',
  #     :mode => 'checkid_setup',
  #     :identity => 'http://specs.openid.net/auth/2.0/identifier_select',
  #     :claimed_id => 'http://specs.openid.net/auth/2.0/identifier_select',
  #     :return_to => 'http://localhost:8080/session/complete',
  #     :realm => 'http://localhost:8080/session',
  #     :assoc_handle => assoc[:assoc_handle]
  #   }
  #   puts @op_endpoint + '?' + @agent.to_openid_query(param)
  #   
  #   # to http://localhost:3000/servers
  #       # ?openid.realm=http%3A%2F%2Flocalhost%3A8080%2Fsession
  #       # &openid.assoc_handle=%7BHMAC-SHA256%7D%7B4812a494%7D%7B3FvybA%3D%3D%7D
  #       # &openid.mode=checkid_setup
  #       # &openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0
  #       # &openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select
  #       # &openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select
  #       # &openid.return_to=http%3A%2F%2Flocalhost%3A8080%2Fsession%2Fcomplete
  #  # got redirect to
  #  # http://localhost:8080/session/complete
  #  #  ?openid.assoc_handle=%7BHMAC-SHA256%7D%7B4812a494%7D%7B3FvybA%3D%3D%7D
  #  #  &openid.claimed_id=http%3A%2F%2Flocalhost%3A3000%2Fservers%2Fjack
  #  #  &openid.identity=http%3A%2F%2Flocalhost%3A3000%2Fservers%2Fjack
  #  #  &openid.mode=id_res
  #  #  &openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0
  #  #  &openid.op_endpoint=http%3A%2F%2Flocalhost%3A3000%2Fservers
  #  #  &openid.response_nonce=2008-04-26T04%3A54%3A19ZZN2x2l
  #  #  &openid.return_to=http%3A%2F%2Flocalhost%3A8080%2Fsession%2Fcomplete
  #  #  &openid.sig=7NV1qRJuXd3zAXh%2FuCCbctKkSBlUL8oG6eUPoawJ9Tc%3D
  #  #  &openid.signed=assoc_handle%2Cclaimed_id%2Cidentity%2Cmode%2Cns%2Cop_endpoint%2Cresponse_nonce%2Creturn_to%2Csigned 
  # end
end