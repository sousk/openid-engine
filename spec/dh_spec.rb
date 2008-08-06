require File.dirname(__FILE__) + '/spec_helper'
require "openid_engine/dh"

describe OpenidEngine::Dh do
  include OpenidEngine::Dh
  
  def mod
    155172898181473697471232257763715539915724801966915404479707795314057629378541917580651227423698188993727816152646631438561595825688188889951272158842675419950341258706556549803580104870537681476726513255747040765857479291291572334510643245094715007229621094194349783925984760375594985848253359305585439638443
  end
  
  def gen
    2
  end
  
  def digester
    Digest::SHA256
  end
  
  def keypairs
    pkey = create_private_key
    pubkey = create_public_key(pkey)
    {:private => pkey, :public => pubkey}
  end
  
  it "should create private key" do
    create_private_key.should be_integer
  end
  
  it "should create public key" do
    create_public_key(123).should be_integer
  end
  
  it "should encode integer to btwoc" do
    encode_btwoc(0).should == "\x00"
    encode_btwoc(127).should == "\x7F"
    encode_btwoc(128).should == "\x00\x80"
    encode_btwoc(255).should == "\x00\xFF"
    encode_btwoc(32768).should == "\x00\x80\x00"
  end
  
  it "should decode integer from btwoc encoded" do
    decode_btwoc("\x00").should == 0
    decode_btwoc("\x7F").should == 127
    decode_btwoc("\x00\x80").should == 128
    decode_btwoc("\x00\xFF").should == 255
    decode_btwoc("\x00\x80\x00").should == 32768
  end
  
  it "should extract btwoced integer from encoded one" do
    encoded = encode_integer(123)
    decode_integer(encoded).should == 123
  end
  
  it "should encrypt secret and decrypt it" do
    alices = keypairs
    bobs = keypairs
    secret = 'hoge' * 8
    
    enc_mac_key = create_enc_mac_key(bobs[:public], alices[:private], secret)
    extracted = extract_enc_mac_key(enc_mac_key, alices[:public], bobs[:private])
    extracted.should == secret
  end
end
