require File.dirname(__FILE__) + '/spec_helper'

describe 'OpenidEngine' do
  include OpenidEngine
  
  describe "#url_encode" do
    it {
      url_encode('&+').should == '%26%2B'
    }
  end
  
  describe "#random_strings" do
    it "should be the length specified" do
      random_strings(32).size.should == 32
    end
    
    it "should consist of chars specified" do
      random_strings(24, [33,33]).should == 33.chr * 24 # should be 
    end
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

end
