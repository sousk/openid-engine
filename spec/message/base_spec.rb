require File.dirname(__FILE__) + '/../spec_helper'
require "openid_engine/message/base"

describe OpenidEngine::Message::Base do
  include OpenidEngine
  
  def get_message(params={})
    OpenidEngine::Message::Base.new params
  end
  
  it "should validate assigned parameters and return self" do
    get_message.should be_instance_of(OpenidEngine::Message::Base)
  end
  
  it "should accept openid queries" do
    msg = get_message 'openid.foo' => "foo"
    msg.should have_key(:foo)
    msg[:foo].should == 'foo'
  end
end
