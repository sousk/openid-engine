#
# Diffie-Hellman implementation code bellow taken from: http://www.sourcesnippets.com/ruby-diffiehellman-key-exchange.html
#
# http://en.wikipedia.org/wiki/Diffie-Hellman
# 
# alice = DH.new(53, 5, 23)
# bob   = DH.new(53, 5, 15)
# alice.generate
# bob.generate
#  
# alice_s = alice.secret(bob.e)
# bob_s   = bob.secret(alice.e)
# puts alice_s
# puts bob_s

class Integer
  # Compute self ^ e mod m
  def mod_exp(e, m)
    result = 1
    b = self
    while e > 0
      result = (result * b) % m if e[0] == 1
      e = e >> 1
      b = (b * b) % m
    end
    result
  end
 
  # A roundabout, slow but fun way of counting bits.
  def bits_set
    ("%b" % self).count('1')
    #to_s(2).count('1')   # alternative
    #count = 0     # alternative
    #byte = self.abs
    #count += byte & 1 and byte >>= 1 until byte == 0   # cf. http://snippets.dzone.com/posts/show/4233
    #count
  end
end
 
 
class DH
  @@default_mod = 155172898181473697471232257763715539915724801966915404479707795314057629378541917580651227423698188993727816152646631438561595825688188889951272158842675419950341258706556549803580104870537681476726513255747040765857479291291572334510643245094715007229621094194349783925984760375594985848253359305585439638443
  @@default_gen = 2
  
  attr_reader :p, :g, :q, :x, :e
 
  # p is the prime, g the generator and q order of the subgroup
  def initialize(p, g, q)
    @p = p
    @g = g
    @q = q
  end
 
  # generate the [secret] random value and the public key
  def generate(tries=16)
    tries.times do
      @x = rand(@q)
      @e = self.g.mod_exp(@x, self.p)
      return @e if self.valid?
    end
    raise ArgumentError, "can't generate valid e"
  end
 
  # validate a public key
  def valid?(_e = self.e)
    _e and _e.between?(2, self.p-2) and _e.bits_set > 1
  end
 
  # compute the shared secret, given the public key
  def secret(f)
    f.mod_exp(self.x, self.p)
  end
end
