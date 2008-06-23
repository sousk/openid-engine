require "openid_engine"
require "openid_engine/yadis"
require "openid_engine/identifier"
require "openid_engine/associator"
require "openid_engine/message/checkid"

module OpenidEngine
  class Rp
    include OpenidEngine
    include OpenidEngine::Identifier
    
    DEFAULT_DH_MODULUS = 155172898181473697471232257763715539915724801966915404479707795314057629378541917580651227423698188993727816152646631438561595825688188889951272158842675419950341258706556549803580104870537681476726513255747040765857479291291572334510643245094715007229621094194349783925984760375594985848253359305585439638443
  	DEFAULT_DH_GEN = 2
  	  
    attr_reader :agent, :policy, :associator
    
    def initialize(policy={})
      @policy = {
        :assoc_type => 'HMAC-SHA256',
        :session_type => 'DH-SHA256'
      }.merge(policy)
      @agent = Agent.new
      @associator = Associator.factory(@policy, @agent, mod_gen)
    end
    
    # override me to use your gen/modulus
		def mod_gen
			[DEFAULT_DH_MODULUS, DEFAULT_DH_GEN]
		end
		
		def request_association(endpoint)
		  @associator.associate(endpoint, @policy)
		end
    
    # TODO: XRI discovery
    # TODO: HTML-based discovery
    # TODO: do not stop invalid url or 404
    def discover(identifier, methods=[:yadis])
      Array(methods).each { |method|
        services = send("discover_by_#{method}", identifier)
        unless services.empty?
          services.each { |service|
            yield(service) if block_given?
          }
        end
      }
      # info = identifier.xri? ? discover_by_xri(identifier) : discover_by_yadis(identifier)
      # info ||= discover_from_html(identifier)
      # yadis = OpenidEngine::Yadis.initiate(identifier)
      # discovery(identifier) do |info|
      # yadis.services
    end
    
    def discover_by_yadis(identifier)
      yadis = OpenidEngine::Yadis.initiate(identifier)
      yadis.services || []
    end
    
    def verify_return_to(return_to, cert)
      r = URI.parse return_to
      c = URI.parse cert
      [:scheme, :host, :port, :path].each { |part|
        value, expectation = r.send(part).to_s.downcase, c.send(part).to_s.downcase
        unless value == expectation
          raise Error, "#{part} of return_to value should be '#{expectation}' but got '#{value}'"
        end
      }
      # see sec 11.1
      if r.query
        c_query = c.query ? c.query.split('&') : []
        r.query.split('&').each {|q|
          unless c_query.include? q
            raise Error, "A query parameter '#{q}' return_to has should also be present in received URL"
          end
        }
      end
    end
    
    # see sec 11.2
    def verify_discovered_information(assertion)
      # fragment MUST NOT be used for verifying
      claimed_id = assertion[:claimed_id].split('#').first
      # cid MUST have been discovered
      # TODO: add HTML based discovery
      discover(claimed_id, [:yadis]) do |service|
        # the information in the assertion MUST be present in the discovered information
        if service[:type].include? TYPE[:signon]
          if Array(service[:uri]).include? assertion[:op_endpoint] &&
              assertion[:op_endpoint] != assertion[:claimed_id] &&
              (assertion[:identity].nil? || service[:localid] == assertion[:identity])
            return
          else
            next # not verified
          end
        end
      end
      raise Error, "there's no discovered information associated with this claimed ID (#{claimed_id})"
    end
  end
end
