module OpenidEngine
  module Associatable
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    # def expired?
    #   created_at + lifetime < Time.now
    # end
    
    module ClassMethods
      DEFAULT_MOD = 1
      DEFAULT_GEN = 2
      DEFAULT_ASSOC_TYPE = 'HMAC-SHA256'
      DEFAULT_SESSION_TYPE = 'DH-SHA256'
      
      def new_from_response(endpoint, response)
        new :op_endpoint => endpoint,
          :handle => response[:assoc_handle],
          :encryption_type => response[:assoc_type],
          :secret => response[:secret],
          :lifetime => response[:expires_in].to_i
      end
      
      def agent
        @agent ||= OpenidEngine::Agent.new
      end
      
      def request(op_endpoint, opts={})
        mod, gen = opts[:mod] || DEFAULT_MOD, opts[:gen] || DEFAULT_GEN
        assoc_type, session_type = opts[:assoc_type] || DEFAULT_ASSOC_TYPE, opts[:session_type] || DEFAULT_SESSION_TYPE
        
        dh = OpenidEngine::Dh.new(mod, gen)
        
        res = request_to_op(op_endpoint, dh, assoc_type, session_type)
        res[:secret] = dh.extract_enc_mac_key res[:enc_mac_key], res[:dh_server_public]
        
        new_from_response op_endpoint, res
      end
      
      private
      def request_to_op(op_endpoint, dh, assoc_type, session_type)
        req = Message::AssociationRequest.init_from_raw({
          :assoc_type => assoc_type,
          :session_type => session_type,
          :dh_modulus => dh.mod,
          :dh_gen => dh.gen,
          :dh_consumer_public => dh.public_key
        }).validate
        raise Error, req.errors unless req.valid?
        
        res = OpenidEngine::Message::AssociationResponse.new(
          agent.direct(op_endpoint, req)
        ).validate.to_raw!
        raise Error, res.errors unless res.valid?

        res
      end
      
    end
  end
end