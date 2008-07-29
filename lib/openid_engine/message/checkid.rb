require "openid_engine/message/base"
module OpenidEngine
  module Message
    
    module PositiveAssertion
      def verify_return_to
        if self[:return_to]
          # see 9.2 Realms:
          # realm is URL contains * (wildcard)
          # realm = Regexp.new self[:realm].split("*.").map{ |part| Regexp.escape part }.join(".*\.?")
          realm = Regexp.new self[:realm]
          unless self[:return_to] =~ realm
            raise ValidationError, "return_to not matched against realm, return_to:#{self[:return_to]}, realm:#{self[:realm]}"
          end
        end
      end
    end
    
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
    
    class CheckidResponse < Base
      include PositiveAssertion
      def initialize(message)
        super
      end
    end
  end
end