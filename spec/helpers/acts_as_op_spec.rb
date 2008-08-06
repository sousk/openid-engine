require File.dirname(__FILE__) + '/op_helper'
require "openid_engine/acts_as_op"

describe OpenidEngine::ActsAsOp do
  include OpenidEngine::ActsAsOp
  
  def mock_rails_controller
    eval("def params; @params ||= {}; end") unless respond_to? :params
  end
  
  def assign_params(*hash)
    Array(hash).each { |k,v| @params[k] = v }
  end
  
  def mock_op
    eval("class OpenidAssociation; end") unless Kernel.const_defined?('OpenidAssociation')
  end
  
  before(:each) do
    mock_op
    mock_rails_controller
  end
  
  it {
    self.should respond_to(:op)
    op.should be_kind_of(OpenidEngine::Op)
  }
  
  it {
    self.send(:process_association_request)
  }
  
#   it {
#     self.should respond_to(:process_checkid_request)
#   }
#   
#   describe "Association handlers" do
#     fixtures :openid_associations
#     
#     it "should retrieve stored association by handle" do
#       
#     end
#   end
end