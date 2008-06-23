require File.dirname(__FILE__) + '/../../spec_helper'

def render_xrds
  render 'users/xrds.xml.erb'
end

describe "/servers/index" do
  fixtures :users
  
  before(:each) do
    @requested_user = users(:quentin)
    render_xrds
  end
  
  it "should have XRDS element" do
    response.should have_text(/xrds:XRDS/)
  end
  
  it "should be a XRDS for OP Identifier" do
    response.should have_tag('Type', 'http://specs.openid.net/auth/2.0/signon')
    response.should have_tag('URI', %r%https?://%)
    response.should have_tag('LocalID', /.+/)
  end
  
end
