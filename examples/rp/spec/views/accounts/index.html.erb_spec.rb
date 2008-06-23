require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/index.html.erb" do
  include AccountsHelper
  
  before(:each) do
    account_98 = mock_model(Account)
    account_99 = mock_model(Account)

    assigns[:accounts] = [account_98, account_99]
  end

  it "should render list of accounts" do
    render "/accounts/index.html.erb"
  end
end

