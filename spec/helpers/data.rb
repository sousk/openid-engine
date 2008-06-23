POLICY_SH256 = {
  :ns => 'http://specs.openid.net/auth/2.0',
  :assoc_type => 'HMAC-SHA256',
  :session_type => 'DH-SHA256'
} unless defined? POLICY_SH256

SERVICE_SERVER = {
  :uri => 'http://localhost:3000/server',
  :type => ['http://specs.openid.net/auth/2.0/server'],
} unless defined? SERVICE_SERVER

SERVICE_SIGNON = {
  :uri => 'http://localhost:3000/server',
  :type => ['http://specs.openid.net/auth/2.0/signon'],
} unless defined? SERVICE_SIGNON

XRDSDATA = {
  :hashed_services => [
    {
      :priority => '0',
      :type => [
        'http://specs.openid.net/auth/2.0/signon'
      ],
      :uri => 'http://www.example.com/server', 
      :localid =>  'http://localhost:3000/users/sou'
    },
    {
      :priority => '1',
      :type => [
        'http://openid.net/signon/1.1'
      ],
      :uri => 'http://www.example.com/server', 
      :delegate => 'http://localhost:3000/'
    },
    {
      :priority => '2',
      :type => [
        'http://openid.net/signon/1.1'
      ],
      :uri => 'http://www.example.com/server', 
      :delegate => 'http://localhost:3000/'
    }
  ],
  :doc => <<-__XRDS__
  <?xml version="1.0" encoding="UTF-8"?>
    <xrds:XRDS
        xmlns:xrds="xri://$xrds"
        xmlns:openid="http://openid.net/xmlns/1.0"
        xmlns="xri://$xrd*($v*2.0)">
      <XRD>

      <Service priority="2">
        <Type>http://openid.net/signon/1.1</Type>
        <URI>http://www.example.com/server</URI>
        <openid:Delegate>http://localhost:3000/</openid:Delegate>
      </Service>
      
        <Service priority="0">
          <Type>http://specs.openid.net/auth/2.0/signon</Type>
          <URI>http://www.example.com/server</URI>
          <LocalID>http://localhost:3000/users/sou</LocalID>
        </Service>

        <Service priority="1">
          <Type>http://openid.net/signon/1.1</Type>
          <URI>http://www.example.com/server</URI>
          <openid:Delegate>http://localhost:3000/</openid:Delegate>
        </Service>
        
      </XRD>
    </xrds:XRDS>
  __XRDS__
} unless defined? XRDSDATA
