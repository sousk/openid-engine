require "openid_engine"
require "base64"
require "openssl"
require "openid_engine/message/associate_response"

module OpenidEngine
  
  class Associator
    class << self
      def factory(policy, agent, mod_gen=[])
        case
        when policy[:session_type] == 'DH-SHA256' || 'DH-SHA1' then associator = DiffieHellmanAssociator
        else raise "not implemented yet"
        end
        associator.new(policy, agent, mod_gen)
      end
    end
  end
  
	# A class for establishing associations with OpenID servers.
	class DiffieHellmanAssociator < Associator
	  
    # see 8.4.2
    # MAC key MUST be the same length
    # .. 160 bits for SHA1, 256 bits for SHA256
    # RP
    #   specifies a modulus, p and a generator, g
    #   chooses a random private key xa, range [1 .. p-1]
    # OP
    #   choose a random private key xb, range
    attr_reader :mod, :gen
    
		def initialize(policy, agent, mod_gen)
		  @agent = agent
		  @mod, @gen = mod_gen
		  @policy = policy # TDOO, maybe obselete, use policy at invoking #associate
		end
		
		def gen_private_key
		  1 + rand(@mod - 2)
		end
		
		def gen_public_key(private_key)
		  mod_exp(@gen, private_key, @mod)
		end
		
		# Establishes an association with an OpenID server, indicated by server_url.
		# Returns a ConsumerAssociation.
		def associate(endpoint, policy={})
		  pkey = gen_private_key
      # dh_public = gen_public_key(pkey)
      # res = @agent.direct(endpoint, make_query(@policy, dh_public))
      # msg = Message.factory(:associate_response, res)
      res = request_association endpoint, gen_public_key(pkey)
      raise Error, "#{res.errors.join(',')}" unless res.valid?
      res[:secret] = extract_secret(res, pkey, @mod)
      res
		end
		
    private
		def request_association(endpoint, public_key)
		  res = @agent.direct endpoint, Message.factory(:associate_request, {
		    :assoc_type => @policy[:assoc_type],
				:session_type => @policy[:session_type],
				:dh_modulus => encode_integer(@mod),
				:dh_gen => encode_integer(@gen),
				:dh_consumer_public => encode_integer(public_key)
		  })
		  OpenidEngine::Message::AssociateResponse.new res
		end
		
		def extract_secret(res, private_key, p)
 			dh_server_pub = btwoc_decode Base64.decode64(res[:dh_server_public])
			dh_shared = mod_exp(dh_server_pub, private_key, p)
			enc_mac_key = Base64.decode64(res[:enc_mac_key])
			
			shared = Digest::SHA256.digest(btwoc_encode(dh_shared)) #FIXME
      
			# Bitwise-XOR two equal length strings.
    	# Raises an ArgumentError if strings are different length.
  		raise ArgumentError, "Can't bitwise-XOR a String with a non-String" unless shared.kind_of? String
  		unless enc_mac_key.length == shared.length
  		  raise ArgumentError, "Can't bitwise-XOR strings of different length, mac_key:#{enc_mac_key.length}, shared:#{shared.length}" 
		  end
  		
  		result = (0..enc_mac_key.length-1).collect { |i| enc_mac_key[i] ^ shared[i] }
  		result.pack("C*")
		end
				
    def encode_integer(int)
      Base64.encode64(btwoc_encode(int)).chomp
    end
    
    def btwoc_decode(s)
  		s = "\000" * (4 - s.size % 4) + s
  		n = 0
    	s.unpack('N*').each { |x|
  		  n <<= 32
    		n |= x
    	}
    	n
    end
    
    def btwoc_encode(int)
      bits = int.to_s(2)
  		pad = (8 - bits.size % 8) || (bits[0,1] == '1' ? 8 : 0)
  		bits = ('0' * pad) + bits if pad
  		[bits].pack('B*')
    end
  
  	def mod_exp(p, n, q)
  		n_p = n     # N 
  		y_p = 1     # Y
  		z_p = p  # Z
  		while n_p != 0
  		  if n_p[0] == 1
  		    y_p = (y_p*z_p) % q
        end
    		n_p = n_p >> 1  
        z_p = (z_p * z_p) % q
      end
      y_p
  	end
  
	end #class DiffieHellmanAssociator
		
end