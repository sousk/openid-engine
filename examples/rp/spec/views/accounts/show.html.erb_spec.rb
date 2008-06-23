require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/show.html.erb" do
  include AccountsHelper
  
  before(:each) do
    @account = mock_model(Account)

    assigns[:account] = @account
  end

  it "should render attributes in <p>" do
    render "/accounts/show.html.erb"
  end
end

