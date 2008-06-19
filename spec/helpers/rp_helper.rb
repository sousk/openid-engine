require File.dirname(__FILE__) + '/../spec_helper'
require "openid_engine/rp"
require "openid_engine/yadis"
require "openid_engine/agent"

def mock_yadis_discovery
  doc = mock(OpenidEngine::Yadis::Document)
  yadis = mock(OpenidEngine::Yadis, :document => doc, :services => XRDSDATA[:hashed_services])
  OpenidEngine::Yadis.stub!(:new).and_return(yadis)
  OpenidEngine::Yadis.stub!(:initiate).and_return(yadis)
end
