require "rubygems"
require 'spec'

_LIBDIR = File.expand_path(File.dirname(__FILE__) + '/../lib') # openid_engine

$:.unshift(_LIBDIR) unless
  $:.include?(_LIBDIR) || $:.include?(File.expand_path(_LIBDIR))

require "openid_engine"
require File.dirname(__FILE__) + '/helpers/data'

# TEST_PROVIDER = 'http://localhost:3000/'

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
