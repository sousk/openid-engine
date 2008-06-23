require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/new.html.erb" do
  include AccountsHelper
  
  before(:each) do
    @account = mock_model(Account)
    @account.stub!(:new_record?).and_return(true)
    assigns[:account] = @account
  end

  it "should render new form" do
    render "/accounts/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", accounts_path) do
    end
  end
end


