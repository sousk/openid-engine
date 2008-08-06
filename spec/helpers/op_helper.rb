require File.dirname(__FILE__) + '/../spec_helper'
require "openid_engine/op"
require "openid_engine/acts_as_op"

include OpenidEngine::ActsAsOp

def mock_rails_controller
  eval("def params; @params ||= {}; end") unless respond_to? :params
  unless Kernel.const_defined?('OpenidAssociation')
    eval("class OpenidAssociation; end")
    OpenidAssociation.stub!(:find_by_handle).and_return(mocked_assoc)
  end
end

def valid_params
  {
    :claimed_id => 'http://example.com/claimed_id',
    :identity => 'http://example.com/identity',
    :return_to => 'http://example.com/return_to',
    :realm => 'http://example.com/',
    :assoc_handle => '1'
  }
end

def mocked_assoc
  unless @assoc
    @assoc = Object.new
    @assoc.stub!(:handle).and_return('handle')
    @assoc.stub!(:encryption_type).and_return('HMAC-SHA256')
    @assoc.stub!(:secret).and_return('secret')
  end
  @assoc
end