require File.dirname(__FILE__) + '/../../spec_helper'

describe "/servers/server_xrds" do
  before(:each) do
    render 'servers/xrds.xml.erb'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    # response.should have_tag('p', /Find me in app\/views\/servers\/server_xrds/)
    response.should be_success
    response.should have_tag('Type', 'http://specs.openid.net/auth/2.0/server')
    response.should have_tag('URI', %r%https?://.+%)
  end
end
