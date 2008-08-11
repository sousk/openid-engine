module OpenidEngine
  DEBUG = true
  
  TYPE = {
    :ns => 'http://specs.openid.net/auth/2.0',
    :server => 'http://specs.openid.net/auth/2.0/server',
    :signon => 'http://specs.openid.net/auth/2.0/signon',
    :identifier_select => 'http://specs.openid.net/auth/2.0/identifier_select'
  }
  
  def random_strings(size, range=[33,126])
    source = (range[0]..range[1]).to_a
    (0...size).collect {
      source[Kernel.rand(source.size)].chr
    }.join
  end
  
  def url_encode(str)
    str.to_s.gsub(/[^\w\.\-]/n) { |ch| sprintf('%%%02X', ch[0]) }
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
	
	def encode_integer(int)
	  Base64.encode64(encode_btwoc(int)).chomp
	end
	
	def decode_integer(str)
	  decode_btwoc Base64.decode64(str)
	end
	
  def log(stat)
    puts "::::::::::::#{stat}" if DEBUG
  end
  
  class Error < StandardError
  end
end
