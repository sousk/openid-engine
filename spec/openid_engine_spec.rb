require File.dirname(__FILE__) + '/spec_helper'

describe 'OpenidEngine' do
  include OpenidEngine
  
  describe "#random_strings" do
    it "should be the length specified" do
      random_strings(32).size.should == 32
    end
    
    it "should consist of chars specified" do
      random_strings(24, [33,33]).should == 33.chr * 24 # should be 
    end
  end

end
