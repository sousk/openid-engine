module OpenidEngine
  module Util
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
    
  end
end