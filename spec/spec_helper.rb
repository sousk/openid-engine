require "rubygems"
require 'spec'

_LIBDIR = File.expand_path(File.dirname(__FILE__) + '/../lib') # openid_engine

$:.unshift(_LIBDIR) unless
  $:.include?(_LIBDIR) || $:.include?(File.expand_path(_LIBDIR))

require "openid_engine"

# TEST_PROVIDER = 'http://localhost:3000/'
# XRDSDATA = {
#   :uri => 'http://localhost:3000/',
#   :hashed_services => [
#     {
#       :priority => '0',
#       :type => [
#         'http://specs.openid.net/auth/2.0/signon', 
#         'http://openid.net/sreg/1.0', 
#         'http://openid.net/extensions/sreg/1.1', 
#         'http://schemas.openid.net/pape/policies/2007/06/phishing-resistant', 
#         'http://openid.net/srv/ax/1.0', 
#       ],
#       :uri => 'http://www.myopenid.com/server', 
#       :localid =>  'http://localhost:3000/users/sou'
#     },
#     {
#       :priority => '1',
#       :type => [
#         'http://openid.net/signon/1.1', 
#         'http://openid.net/sreg/1.0', 
#         'http://openid.net/extensions/sreg/1.1', 
#         'http://schemas.openid.net/pape/policies/2007/06/phishing-resistant', 
#         'http://openid.net/srv/ax/1.0'        
#       ],
#       :uri => 'http://www.myopenid.com/server', 
#       :delegate => 'http://localhost:3000/'
#     },
#     {
#       :priority => '2',
#       :type => [
#         'http://openid.net/signon/1.1', 
#         'http://openid.net/sreg/1.0', 
#         'http://openid.net/extensions/sreg/1.1', 
#         'http://schemas.openid.net/pape/policies/2007/06/phishing-resistant', 
#         'http://openid.net/srv/ax/1.0',         
#       ],
#       :uri => 'http://www.myopenid.com/server', 
#       :delegate => 'http://localhost:3000/'
#     }
#   ],
#   :doc => <<-__XRDS__
#   <?xml version="1.0" encoding="UTF-8"?>
#     <xrds:XRDS
#         xmlns:xrds="xri://$xrds"
#         xmlns:openid="http://openid.net/xmlns/1.0"
#         xmlns="xri://$xrd*($v*2.0)">
#       <XRD>
# 
#       <Service priority="2">
#         <Type>http://openid.net/signon/1.1</Type>
#         <Type>http://openid.net/sreg/1.0</Type>
#         <Type>http://openid.net/extensions/sreg/1.1</Type>
#         <Type>http://schemas.openid.net/pape/policies/2007/06/phishing-resistant</Type>
#         <Type>http://openid.net/srv/ax/1.0</Type>
#         <URI>http://www.myopenid.com/server</URI>
#         <openid:Delegate>http://localhost:3000/</openid:Delegate>
#       </Service>
#       
#         <Service priority="0">
#           <Type>http://specs.openid.net/auth/2.0/signon</Type>
#           <Type>http://openid.net/sreg/1.0</Type>
#           <Type>http://openid.net/extensions/sreg/1.1</Type>
#           <Type>http://schemas.openid.net/pape/policies/2007/06/phishing-resistant</Type>
#           <Type>http://openid.net/srv/ax/1.0</Type>
#           <URI>http://www.myopenid.com/server</URI>
#           <LocalID>http://localhost:3000/users/sou</LocalID>
#         </Service>
# 
#         <Service priority="1">
#           <Type>http://openid.net/signon/1.1</Type>
#           <Type>http://openid.net/sreg/1.0</Type>
#           <Type>http://openid.net/extensions/sreg/1.1</Type>
#           <Type>http://schemas.openid.net/pape/policies/2007/06/phishing-resistant</Type>
#           <Type>http://openid.net/srv/ax/1.0</Type>
#           <URI>http://www.myopenid.com/server</URI>
#           <openid:Delegate>http://localhost:3000/</openid:Delegate>
#         </Service>
#         
#       </XRD>
#     </xrds:XRDS>
#   __XRDS__
# }
# 
# PARAMS = {
#   :user_supplied_identifier => 'http://localhost/user_supplied_identifier'
#   # :ns => OpenID::OPENID2_NS,
#   # :identity => 'http://test.host/servers/jack',
#   # :return_to => 'http://test.host/return_to',
#   # :op_endpoint => 'http://test.host/server',
#   # :realm => 'http://test.host/', #trust root
#   # :claimed_id => 'http://test.host/servers/jack',
#   # :immediate => false,
#   # :assoc_handle => nil,
#   # :assoc_type => 'HMAC-SHA256'
# }
# 
# def p(key=nil)
#   key ? PARAMS[key] : PARAMS
# end
