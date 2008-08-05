require "openid_engine/message/base"
module OpenidEngine
  module Message
    class CheckidRequest < Base      
      def initialize(message)
        self[:mode] = 'checkid_setup' # default value
        add_requires :mode, :claimed_id, :identity, :assoc_handle # see sec 9.1: openid.identity, openid.claimed_id, openid.assoc_handle
        add_requires :realm unless message[:return_to] # must be sent if openid.return_to is omitted (sec 9.1)
        
        add_rules :mode => included('checkid_setup', 'checkid_immediate')
        self[:realm] = message[:return_to].dup if message[:return_to] # see sec 9.1: return_to is the default value (and overriden if message has)
        
        super
      end
    end
  end
end