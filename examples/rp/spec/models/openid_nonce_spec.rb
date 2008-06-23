require File.dirname(__FILE__) + '/../spec_helper'

describe OpenidNonce do
  before(:each) do
    @openid_nonce = OpenidNonce.new
  end

  it "should be valid" do
    @openid_nonce.should be_valid
  end
end
