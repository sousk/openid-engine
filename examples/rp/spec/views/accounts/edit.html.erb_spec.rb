require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/edit.html.erb" do
  include AccountsHelper
  
  before do
    @account = mock_model(Account)
    assigns[:account] = @account
  end

  it "should render edit form" do
    render "/accounts/edit.html.erb"
    
    response.should have_tag("form[action=#{account_path(@account)}][method=post]") do
    end
  end
end


