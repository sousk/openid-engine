require 'association'

module OpenidEngine
  # module Rp
    class RpAssociation < Association
  		# see 8.4.2
      # MAC key MUST be the same length
      # .. 160 bits for SHA1, 256 bits for SHA256
      # RP
      #   specifies a modulus, p and a generator, g
      #   chooses a random private key xa, range [1 .. p-1]
      # OP
      #   choose a random private key xb, range
      BASIC_RULES = {
        :required => [
          [:ns, [TYPE_URI[:auth2p0], TYPE_URI[:auth1p1]]],
          [:mode, 'associate'], 
          [:assoc_type, ['HMAC-SHA1', 'HMAC-SHA256']],
          [:session_type, ['DH-SHA1', 'DH-SHA256', 'no-encryption']]
        ]
      }
      DH_RULES = [
        :required => [:dh_modulus, :dh_gen, :dh_consumer_public]
      ]
      
      def initialize(policy)
        @policy = policy
        @rules = {
          :required => BASIC_RULE[:required] + DH_RULE[:required]
        }
      end
    
      def validate_policy
        super
        unless policy[:session_type] == 'DH-SHA256'
          raise "not implemented yet"
        end
      end
    end
  # end
end
