require "openid_engine"
require "openid_engine/yadis"
require "openid_engine/identifier"
require "openid_engine/associator"

# TODO: OpenID Authentication 1.1 Compatibility mode, http://openid.net/specs/openid-authentication-2_0.html#compat_mode
module OpenidEngine
  class Rp
    include OpenidEngine::Identifier
    
    DEFAULT_DH_MODULUS = 155172898181473697471232257763715539915724801966915404479707795314057629378541917580651227423698188993727816152646631438561595825688188889951272158842675419950341258706556549803580104870537681476726513255747040765857479291291572334510643245094715007229621094194349783925984760375594985848253359305585439638443
  	DEFAULT_DH_GEN = 2
  	
  	DEFAULT_POLICY = {
      :ns =>'http://specs.openid.net/auth/2.0',
      :assoc_type => 'HMAC-SHA256',
      :session_type => 'DH-SHA256'
    }
  
    attr_reader :agent, :policy, :associator
    
    def initialize(policy={})
      @policy = policy
      DEFAULT_POLICY.each{ |k, v| @policy[k] = v unless @policy.has_key?(k) }
      @agent = Agent.new
      @associator = Associator.factory(policy, @agent, mod_gen)
    end
    
    # override me to use your gen/modulus
		def mod_gen
			[DEFAULT_DH_MODULUS, DEFAULT_DH_GEN]
		end
		
		def request_association(endpoint)
		  @associator.associate endpoint, @policy
		end
    
    # TODO: XRI discovery
    # TODO: HTML-based discovery
    def discover_services(identifier)
      # info = identifier.xri? ? discover_by_xri(identifier) : discover_by_yadis(identifier)
      # info ||= discover_from_html(identifier)
      yadis = OpenidEngine::Yadis.initiate(identifier)
      # discovery(identifier) do |info|
      yadis.services
    end
    
    private
    # def find_adapted_service(type)
    #   @services.each { |s| return s if s[:type].include? TYPE_URI[type] }
    #   nil
    # end
  end
end
