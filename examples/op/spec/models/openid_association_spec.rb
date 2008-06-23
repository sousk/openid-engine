require File.dirname(__FILE__) + '/../spec_helper'

describe OpenidAssociation do
  before(:each) do
    @openid_association = OpenidAssociation.new
  end

  it "should be valid" do
    @openid_association.should be_valid
  end
end
