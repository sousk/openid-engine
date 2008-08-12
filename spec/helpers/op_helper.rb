require File.dirname(__FILE__) + '/../spec_helper'
require "openid_engine/op"
require "openid_engine/acts_as_op"

include OpenidEngine::ActsAsOp

def mod
  155172898181473697471232257763715539915724801966915404479707795314057629378541917580651227423698188993727816152646631438561595825688188889951272158842675419950341258706556549803580104870537681476726513255747040765857479291291572334510643245094715007229621094194349783925984760375594985848253359305585439638443
end

def gen
  2
end

def mock_rails_controller
  unless respond_to? :params
    # eval("def params; @params ||= {}; end") 
    def params
      @params ||= {}
    end
    
    def assign_params(*hash)
      Array(hash).each { |k,v| @params[k] = v }
    end
  end
  
  unless Kernel.const_defined?('OpenidAssociation')
    eval("class OpenidAssociation; end")
  end
end

def mock_op_association(assoc=mocked_assoc)
  OpenidAssociation.stub!(:find_by_handle).and_return assoc # to be obsoleted
  OpenidAssociation.stub!(:find_by_op_endpoint).and_return assoc # to be obsoleted
  OpenidAssociation.stub!(:new)
end

def mock_dh
  dh = OpenidEngine::Dh.new mod, gen
  OpenidEngine::Dh.stub!(:new).and_return dh
  dh
end

def mock_agent
  @agent = OpenidEngine::Agent.new
  @agent.stub!(:request).and_return "pls overritde @agent#request"
  
  OpenidEngine::Agent.stub!(:new).and_return @agent
end

def valid_params
  {
    :claimed_id => 'http://example.com/claimed_id',
    :identity => 'http://example.com/identity',
    :return_to => 'http://example.com/return_to',
    :realm => 'http://example.com/',
    :assoc_handle => '1'
  }
end

def mocked_assoc
  unless @assoc
    @assoc = Object.new
    @assoc.stub!(:handle).and_return('handle')
    @assoc.stub!(:encryption_type).and_return('HMAC-SHA256')
    @assoc.stub!(:secret).and_return('secret')
  end
  @assoc
end