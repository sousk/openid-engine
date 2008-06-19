# 
# the part of this code taken from
# Mark Quinn's openid (http://rubyforge.org/projects/openid/) implementation
#
require "openid_engine"

module OpenidEngine
  module NumCrypto
    def to_btwoc
  		bits = self.to_s(2)
  		pad = (8 - bits.size % 8) || (bits[0,1] == '1' ? 8 : 0)
  		bits = ('0' * pad) + bits if pad
  		[bits].pack('B*')
	  end
	  
	  # This code is taken from this post[http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/19098]
  	# by Eric Lee Green. x.mod_exp(n,q) returns x ** n % q
  	def mod_exp(n,q)
  		n_p = n     # N 
  		y_p = 1     # Y
  		z_p = self  # Z
  		while n_p != 0
  		  if n_p[0] == 1
  		    y_p = (y_p*z_p) % q
        end
    		n_p = n_p >> 1  
        z_p = (z_p * z_p) % q
      end
      y_p
  	end
  end
end
class Fixnum; include OpenidEngine::NumCrypto; end
class Bignum; include OpenidEngine::NumCrypto; end

module OpenidEngine  
  class Association  	
  	class << self
  	  # see 4.2 at OpenID 2.0 spec

  	  def btwoc_decode(s)
    		s = "\000" * (4 - s.size % 4) + s
    		n = 0
      	s.unpack('N*').each { |x|
  			  n <<= 32
      		n |= x
      	}
      	n
  	  end
	  end
  	
  	protected
	  def validate_policy(ruleset)
	    ruleset[:required].each { |key, rule|
	      case
          when rule.nil?
            should_be = 'exist'
            valid = @policy.has_key?(key)
          when rule.kind_of?(Array)
            should_be = "one of #{rule.join(', ')}"
            valid = rule.include? @policy[key]
          else
            should_be = rule
            valid = @policy[key] == rule
        end
        
        unless valid
          raise Error, "policy[:%s] should be '%s' but got '%s'" % [key, should_be, @policy[key] || 'nothing']
        end
      }  
    end
      	
  end
		
	class RpAssociation < Association
	  
    def initialize(policy, p=nil, g=nil)
      @policy = policy
      # @p = p || DEFAULT_DH_MODULUS
      # @g = g || DEFAULT_DH_GEN
    end
    
    def validate
      validate_policy(BASIC_RULES)
      validate_policy(DH_RULES)
      unless @policy[:session_type] == 'DH-SHA256'
        raise "not implemented yet"
      end
    end
    
    def request
      # openid
      # private_key = (1 + rand(p - 2))
      # dh_public = g.mod_exp(private_key, p)
      # janrain
      # @private = OpenID::CryptUtil.rand(@modulus-2) + 1
      # @public = DiffieHellman.powermod(@generator, @private, @modulus)
      # private_key = 1 + rand(@p - 2)
      # dh_public = @g.mod_exp(private_key, @p)
			
    end
    
    #     def dh_gen
    #       Base64.encode64(self.class.btwoc_encode(DEFAULT_DH_GEN)).delete("\n")
    # end
    # 
    #     def dh_modulus
    #   Base64.encode64(self.class.btwoc_encode(DEFAULT_DH_MODULUS)).delete("\n")
    #     end
  	
  end
end

