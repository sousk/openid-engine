require "openid_engine/message/base"
module OpenidEngine
  module Message
    class AssociationRequest < Base
      
      class << self
        include OpenidEngine
        
        def init_from_raw(msg)
          [:dh_modulus, :dh_gen, :dh_consumer_public].each {|key|
            msg[key] = encode_integer msg[key] if msg.has_key?(key)
          }
          self.new msg
        end
      end
      
      def initialize(message)
        add_requires :mode, :assoc_type, :session_type
        add_rules :mode => matched('associate'),
          :assoc_type => included('HMAC-SHA1', 'HMAC-SHA256'),
  				:session_type => included('no-encryption', 'DH-SHA1', 'DH-SHA256')
        self[:mode] = 'associate'
        
        if ['DH-SHA1', 'DH-SHA256'].include? message[:session_type]
          add_requires :dh_modulus, :dh_gen, :dh_consumer_public
        end
        
        super
      end
    end
  end
end