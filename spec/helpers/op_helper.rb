require File.dirname(__FILE__) + '/../spec_helper'
require "openid_engine/op"

def mock_associations
  assocs = Object.new
  assocs.stub!(:find_by_handle)
  @op.stub!(:associations).and_return assocs
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

def op
  @op ||= OpenidEngine::Op.new
end

def assoc
  unless @assoc
    @assoc = Object.new
    @assoc.stub!(:handle).and_return('handle')
    @assoc.stub!(:encryption_type).and_return('HMAC-SHA256')
    @assoc.stub!(:secret).and_return('secret')
  end
  @assoc
end