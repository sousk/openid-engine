require File.dirname(__FILE__) + '/spec_helper'
require "openid_engine/dh"

describe OpenidEngine::Dh do
  
  before(:each) do
    @mod = 155172898181473697471232257763715539915724801966915404479707795314057629378541917580651227423698188993727816152646631438561595825688188889951272158842675419950341258706556549803580104870537681476726513255747040765857479291291572334510643245094715007229621094194349783925984760375594985848253359305585439638443
    @gen = 2
    @dh = OpenidEngine::Dh.new @mod, @gen
  end
  
  it "should create private key" do
    @dh.private_key.should be_integer
  end
  
  it "should create public key" do
    @dh.public_key.should be_integer
  end
  
  it "should encode integer to btwoc" do
    @dh.encode_btwoc(0).should == "\x00"
    @dh.encode_btwoc(127).should == "\x7F"
    @dh.encode_btwoc(128).should == "\x00\x80"
    @dh.encode_btwoc(255).should == "\x00\xFF"
    @dh.encode_btwoc(32768).should == "\x00\x80\x00"
  end
  
  it "should decode integer from btwoc encoded" do
    @dh.decode_btwoc("\x00").should == 0
    @dh.decode_btwoc("\x7F").should == 127
    @dh.decode_btwoc("\x00\x80").should == 128
    @dh.decode_btwoc("\x00\xFF").should == 255
    @dh.decode_btwoc("\x00\x80\x00").should == 32768
  end
  
  it "should extract btwoced integer from encoded one" do
    encoded = @dh.encode_integer(123)
    @dh.decode_integer(encoded).should == 123
  end
  
  it "should encrypt secret and decrypt it" do
    alice = @dh
    bob = OpenidEngine::Dh.new @mod, @gen
    secret = 'hoge' * 8
    
    enc_mac_key = alice.gen_enc_mac_key(bob.public_key, secret)
    extracted = bob.extract_enc_mac_key(enc_mac_key, alice.public_key)
    extracted.should == secret
  end
end
