require "openid_engine/message/base"
module OpenidEngine
  module Message
    class IdRes < Base
      def initialize(message)
        # add_requires :mode, :claimed_id, :identity, :assoc_handle # see sec 9.1 openid.identity, openid.claimed_id, openid.assoc_handle
        # add_requires :realm unless message.has_key? :return_to # see sec 9.1 openid.realm
        # add_rules :mode => included('checkid_setup', 'checkid_immediate')
        # self[:mode] = 'checkid_setup' # default value
        # self[:realm] = message[:return_to] # defalut value
        
        super
      end
    end
  end
end
