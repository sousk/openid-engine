require File.dirname(__FILE__) + '/../helpers/op_helper'
require "openid_engine/message/positive_assertion"

describe OpenidEngine::Message::PositiveAssertion do
  include OpenidEngine
  
  before(:each) do
    @asrt = OpenidEngine::Message::PositiveAssertion.new({
      :op_endpoint => 'http://example.com/op_endpoint',
      :return_to => 'http://example.com/return_to',
      :response_nonce => op.make_nonce,
      :assoc_handle => assoc.handle
    })
  end
  
  it {
    @asrt.should be_valid
    
    @asrt.sign! assoc
    @asrt.should have_key(:signed)
    @asrt.should have_key(:sig)
  }
  
  describe "signed field" do
    it "should be a field comma-speparated list of signed fields" do
      @asrt.sign! assoc
      @asrt.should have_key(:signed)
      
      signed = @asrt[:signed].split(',')
      %w(op_endpoint return_to response_nonce assoc_handle).each { |field|
        signed.should be_include(field)
      }
    end
    
    it "should include 'claimed_id' and 'identity' if present" do
      @asrt[:claimed_id] = 'http://example.com/claimed_id'
      @asrt[:identity] = 'identity'
      @asrt.sign! assoc
      %w(claimed_id identity).each { |field|
        @asrt[:signed].should =~ /#{field}/
      }
    end
  end
  
  describe "sig field" do
    it "should be Base64 encoded signature calculated as specified" do
      @asrt.sign! assoc
      @asrt.should have_key(:sig)
    end
  end
end
