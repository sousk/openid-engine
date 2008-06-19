require "openid_engine"
require "base64"
require "openssl"

module OpenidEngine
  
  class Associator
    class << self
      def factory(policy, agent, mod_gen=[])
        case
        when policy[:session_type] == 'DH-SHA256' || 'DH-SHA1' then associator = DiffieHelmanAssociator
        else raise "not implemented yet"
        end
        associator.new(policy, agent, mod_gen)
      end
    end
  end
  
	# A class for establishing associations with OpenID servers.
	class DiffieHelmanAssociator < Associator
	  
    # see 8.4.2
    # MAC key MUST be the same length
    # .. 160 bits for SHA1, 256 bits for SHA256
    # RP
    #   specifies a modulus, p and a generator, g
    #   chooses a random private key xa, range [1 .. p-1]
    # OP
    #   choose a random private key xb, range
    #
    # BASIC_RULES = {
    #   :required => [
    #     [:ns, [TYPE_URI[:auth2p0], TYPE_URI[:auth1p1]]],
    #     [:mode, 'associate'], 
    #     [:assoc_type, ['HMAC-SHA1', 'HMAC-SHA256']],
    #     [:session_type, ['DH-SHA1', 'DH-SHA256', 'no-encryption']]
    #   ]
    # }
    # DH_RULES = {
    #   :required => [:dh_modulus, :dh_gen, :dh_consumer_public]
    # }
    attr_reader :mod, :gen
    
		def initialize(policy, agent, mod_gen)
		  @agent = agent
		  @mod, @gen = mod_gen
		  @policy = policy
		end
		
		def gen_private_key
		  1 + rand(@mod - 2)
		end
		
		def gen_public_key(private_key)
		  mod_exp(@gen, private_key, @mod)
		end
		
		# Returns modulus and generator for Diffie-Helman.
		# Override this for non-default values.
    # def mod_gen
    #   return DEFAULT_DH_MODULUS, DEFAULT_DH_GEN
    # end
		
		def extract_secret_1(res, private_key, p)
 			dh_server_pub = btwoc_decode Base64.decode64(res[:dh_server_public])
			dh_shared = mod_exp(dh_server_pub, private_key, p)
			enc_mac_key = Base64.decode64(res[:enc_mac_key])
			
			#　secret = Base64.decode64(enc_mac_key) ^ Digest::SHA1.digest(dh_shared.to_btwoc)
      # def String.^(other)
      #         raise ArgumentError, "Can't bitwise-XOR a String with a non-String" \
      #           unless other.kind_of? String
      #         raise ArgumentError, "Can't bitwise-XOR strings of different length" \
      #           unless self.length == other.length
      #         result = (0..self.length-1).collect { |i| self[i] ^ other[i] }
      #         result.pack("C*")\
      #       end
    	
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
		
		# This code is taken from this post:
    # <http://blade.nagaokaut.ac.jp/cgi-bin/scat.\rb/ruby/ruby-talk/19098>
    # by Eric Lee Green.
    def powermod_janrain(x, n, q)
      counter=0
      n_p=n
      y_p=1
      z_p=x
      while n_p != 0
        if n_p[0]==1
          y_p=(y_p*z_p) % q
        end
        n_p = n_p >> 1
        z_p = (z_p * z_p) % q
        counter += 1
      end
      return y_p
    end
		def extract_secret_janrain(res, private_key, p)
		  
      # def extract_secret(response)
      #         dh_server_public64 = response.get_arg(OPENID_NS, 'dh_server_public',
      #                                               NO_DEFAULT)
      #         enc_mac_key64 = response.get_arg(OPENID_NS, 'enc_mac_key', NO_DEFAULT)
      #         dh_server_public = CryptUtil.base64_to_num(dh_server_public64)
      #         enc_mac_key = Util.from_base64(enc_mac_key64)
      #         return @dh.xor_secret(self.class.hashfunc,
      #                               dh_server_public, enc_mac_key)
      #       end
		  
      dh_server_public = OpenidEngine::Association.btwoc_decode Base64.decode64(res[:dh_server_public])
      enc_mac_key = Base64.decode64 res[:enc_mac_key]
      
      # return @dh.xor_secret(self.class.hashfunc, dh_server_public, enc_mac_key)
      #   hashfunc is proc of Digest::SHA256.digest(text)
      # xor_secret method is
      #   def xor_secret(algorithm, composite, secret)
      #     dh_shared = get_shared_secret(composite)
      #     packed_dh_shared = OpenID::CryptUtil.num_to_binary(dh_shared)
      #     hashed_dh_shared = algorithm.call(packed_dh_shared)
      #     return DiffieHellman.strxor(secret, hashed_dh_shared)
      #   end
      
      secret = enc_mac_key
      dh_shared = powermod_janrain(dh_server_public, private_key, p) # == dh_server_public.mod_exp(private_key, p)
      packed_dh_shared = dh_shared.to_btwoc # == num_to_binary(dh_shared)
      hashed_dh_shared = Digest::SHA256.digest(packed_dh_shared)
      
      # def DiffieHellman.strxor(s, t)
      #   if s.length != t.length
      #     raise ArgumentError, "strxor: lengths don't match. " +
      #       "Inputs were #{s.inspect} and #{t.inspect}"
      #   end
      # 
      #   if String.method_defined? :bytes
      #     s.bytes.zip(t.bytes).map{|sb,tb| sb^tb}.pack('C*')
      #   else
      #     indices = 0...(s.length)
      #     chrs = indices.collect {|i| (s[i]^t[i]).chr}
      #     chrs.join("")
      #   end
      # end
      indices = 0...(secret.length)
      chrs = indices.collect {|i| (secret[i]^hashed_dh_shared[i]).chr}
      result = chrs.join("")
      
		end
		
		# Establishes an association with an OpenID server, indicated by server_url.
		# Returns a ConsumerAssociation.
		def associate(endpoint, policy)
		  pkey = gen_private_key
			dh_public = gen_public_key(pkey)
      res = @agent.direct endpoint, make_query(policy, dh_public)
			res[:secret] = extract_secret_1(res, pkey, @mod)
      res
		end
		
		def make_query(policy, dh_public)
		  {
			  :ns => policy[:ns],
				:mode => 'associate',
				:assoc_type => policy[:assoc_type],
				:session_type => policy[:session_type],
				:dh_modulus => encode_integer(@mod),
				:dh_gen => encode_integer(@gen),
				:dh_consumer_public => encode_integer(dh_public)
			}
		end
	
	  def extract_secret(association_response)
      extract_secret_markquinns(association_response)
    end
    
    private
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
  
    def extract_secret_markquinns(res)
      session_type = res[:session_type]
      # dh_server_pub = from_btwoc(Base64.decode64(get_result('dh_server_public')))
      # enc_mac_key = get_result('enc_mac_key')
      # dh_shared = dh_server_pub.mod_exp(private_key, p)
      # secret = Base64.decode64(enc_mac_key) ^ Digest::SHA1.digest(dh_shared.to_btwoc)
		
  		dh_server_pub = btwoc_decode Base64.decode64(res[:dh_server_public])
  		dh_shared = mod_exp(dh_server_pub, private_key, p)
  		shared = Digest::SHA256.digest btwoc_encode(dh_shared)
  		enc_mac_key = Base64.decode64 res[:enc_mac_key]
    
  		# Bitwise-XOR two equal length strings.
    	# Raises an ArgumentError if strings are different length.
  		raise ArgumentError, "Can't bitwise-XOR a String with a non-String" unless shared.kind_of? String
  		raise ArgumentError, "Can't bitwise-XOR strings of different length" unless enc_mac_key.length == shared.length
		
  		result = (0..enc_mac_key.length-1).collect { |i| enc_mac_key[i] ^ shared[i] }
  		result.pack("C*")
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
  
	end #class DiffieHelmanAssociator
		
end