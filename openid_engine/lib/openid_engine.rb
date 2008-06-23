module OpenidEngine
  TYPE = {
    :ns => 'http://specs.openid.net/auth/2.0',
    :server => 'http://specs.openid.net/auth/2.0/server',
    :signon => 'http://specs.openid.net/auth/2.0/signon',
    :identifier_select => 'http://specs.openid.net/auth/2.0/identifier_select'
  }
  
  class Error < StandardError
  end
end
