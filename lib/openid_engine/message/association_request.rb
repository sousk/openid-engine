require "openid_engine/message/base"
module OpenidEngine
  module Message
    
    class AssociationRequest < Base
      def initialize(message)
        add_requires :mode, :assoc_type, :session_type
        add_rules :mode => matched('associate'),
          :assoc_type => included('HMAC-SHA1', 'HMAC-SHA256'),
  				:session_type => included('no-encryption', 'DH-SHA1', 'DH-SHA256')
        self[:mode] = 'associate'
        
        super
      end
    end
  end
end