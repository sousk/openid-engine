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
  
  def log(stat)
    puts "::::::::::::#{stat}" if DEBUG
  end
  
  class Error < StandardError
  end
end
