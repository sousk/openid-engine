require "openid_engine/message/base"
module OpenidEngine
  module Message
    
    class AssociationResponse < Base
      include OpenidEngine
      
      def initialize(message)
        add_requires :assoc_handle, :assoc_type, :expires_in, :session_type
        add_rules :assoc_handle => [less_than(255), charcode_between(33, 126)],
  	      :expires_in => numeric
  	      
  	    if %w(DH-SHA1 DH-SHA256).include? message[:session_type]
          add_requires :dh_server_public, :enc_mac_key
        else
          add_requires :mac_key
        end
        
        super
      end
      
      def dh?
        %w(DH-SHA1 DH-SHA256).include? self[:session_type]
      end
      
      def to_raw!
        if self[:enc_mac_key]
          self[:enc_mac_key] = Base64.decode64 self[:enc_mac_key]
        end
        
        if self[:dh_server_public]
          self[:dh_server_public] = decode_btwoc Base64.decode64(self[:dh_server_public])
        end
        
        self
      end
      
      private
      # validation rule
      def charcode_between(from, to)
        lambda { |k, v|
          v.to_s.each_byte{ |code|
            unless from <= code && code <= to
              raise ValidationError, "value of #{k} (#{v}) includes invalid character '#{code}', should be between #{from} and #{to}"
            end
          }
        }
      end
    end
  end
end