require "openid_engine/message/base"

module OpenidEngine
  module Message
    class PositiveAssertion < Base
      include OpenidEngine
      
      def initialize(message)
        add_requires :mode, :op_endpoint, :return_to, :response_nonce, :assoc_handle # :signed, :sign
        add_rules :mode => matched('id_res')
        self[:mode] = 'id_res'
        
        super
      end
      
      def sign!(assoc)
        self.merge! sign(assoc)
      end
      
      def sign(assoc)
        signing_keys = [:op_endpoint, :return_to, :response_nonce, :assoc_handle]
        signing_keys << :identity if self[:identity]
        signing_keys << :claimed_id if self[:claimed_id]
        
        {:sig => create_signature(signing_keys, assoc), :signed => signing_keys.map {|key| key.to_s }.join(',')}
      end
      
      def create_signature(keys, assoc)
        keyvalues = keys.map{ |key|
           "%s:%s\n" % [key, self[key]]
        }.join

        digester = assoc.encryption_type == 'HMAC-SHA1' ? OpenSSL::Digest::SHA1.new : OpenSSL::Digest::SHA256.new
        sig = Base64.encode64(OpenSSL::HMAC.digest(digester, assoc.secret, keyvalues)).chomp
        sig
      end
    end
  end
end
