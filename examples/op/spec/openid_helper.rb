require File.dirname(__FILE__) + '/spec_helper'
require 'openid_engine/rp'

module OpenidHelper
  CONST = {
    :ns =>'http://specs.openid.net/auth/2.0',
    :assoc_type => 'HMAC-SHA256',
    :session_type => 'DH-SHA256'
  }
  
  def do_assoc_request(path)
    
    param = CONST.merge({
      
    })
    post path
  end
  
  private
  def associator
    
  end
end