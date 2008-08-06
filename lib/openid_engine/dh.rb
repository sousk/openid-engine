require "base64"

module OpenidEngine::Dh
  def create_private_key
    1 + rand(mod - 2)
  end
  
  def create_public_key(private_key)
	  mod_exp(gen, private_key, mod)
	end
	
	def encode_integer(int)
	  Base64.encode64(encode_btwoc(int)).chomp
	end
	
	def decode_integer(str)
	 decode_btwoc Base64.decode64(str)
	end
	
	def encode_btwoc(int)
	  bits = int.to_s(2)
		pad = (8 - bits.size % 8) || (bits[0,1] == '1' ? 8 : 0)
		bits = ('0' * pad) + bits if pad
		[bits].pack('B*')
	end
	
	def decode_btwoc(s)
	 	s = "\000" * (4 - s.size % 4) + s
		n = 0
  	s.unpack('N*').each { |x|
		  n <<= 32
  		n |= x
  	}
  	n
	end
	
	def create_enc_mac_key(others_pubkey, my_pkey, secret)
    dh_shared = mod_exp(others_pubkey, my_pkey, mod)
    hashed_shared = digester.digest btwoc_encode(dh_shared)
    strxor(secret, hashed_shared)
  end
  
  def extract_enc_mac_key(enc_mac_key, others_pubkey, my_pkey, p=mod)
		_shared_key = mod_exp(others_pubkey, my_pkey, p)
		shared_key = digester.digest btwoc_encode(_shared_key)
    
		raise ArgumentError, "Can't bitwise-XOR a String with a non-String" unless shared_key.kind_of? String
		unless enc_mac_key.length == shared_key.length
		  raise ArgumentError, "Can't bitwise-XOR strings of different length, mac_key:#{enc_mac_key.length}, shared:#{shared_key.length}" 
	  end
		
		result = (0..enc_mac_key.length-1).collect { |i| enc_mac_key[i] ^ shared_key[i] }
		result.pack("C*")
  end
  
	
	private
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
	
	def strxor(s, t)
    result = (0..s.length-1).collect { |i| (s[i] ^ t[i]).chr }
    result.join
  end
end
