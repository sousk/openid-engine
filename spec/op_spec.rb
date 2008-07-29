require File.dirname(__FILE__) + '/helpers/op_helper'

describe OpenidEngine::Op do
  before(:each) do
    @op = OpenidEngine::Op.new
  end
  
  describe "#associations" do
    before(:each) do
      mock_associations
      @assocs = @op.associations
    end
    
    it {
      @assocs.should respond_to(:find_by_handle)
    }
  end
  
  describe "#verify_return_to" do
    before(:each) do
      @params = valid_params
    end
    
    it "should pass validation with valid parameters" do
      [
        # realm, return_to
        ['http://example.com/', ['http://example.com/', 'http://example.com/foo']],
        ['http://example.com/foo', ['http://example.com/foo/', 'http://example.com/foo/bar']],
        ['https://example.com/', ['https://example.com/foo']],
        ['http://*.example.com/', ['http://example.com/foo', 'http://bar.example.com/foo', 'http://hoge.huni.example.com/foo']],
        ['http://example.com:80/', ['http://example.com:80/foo']]
      ].each { |realm, return_tos|
        return_tos.each { |return_to|
          lambda {
            @op.verify_return_to_against_realm :realm => realm, :return_to => return_to
          }.should_not raise_error(OpenidEngine::Error)
        }
      }
    end
    
    def run_verification_spec(error_msg, params)
      lambda {
        @op.verify_return_to_against_realm params
      }.should raise_error(OpenidEngine::Error, /#{error_msg}/)
    end
    
    it "should raise error when scheme mismatched" do
      run_verification_spec 'scheme', :realm => 'https://example.com/', :return_to => 'http://example.com/'
    end
    
    it "should raise error when port mismatched" do
      run_verification_spec 'port', :realm => 'http://example.com:80/', :return_to => 'http://example.com:8080/foo'
    end
    
    it "should raise error when auhtority section mismatched" do
      run_verification_spec 'authority', :realm => 'http://*.example.com/', :return_to => 'http://example.com.tw/'
    end
    
    it "should raise error when paths mismatched" do
      run_verification_spec 'path', :realm => 'http://example.com/foo', :return_to => 'http://example.com/foos'
    end
  end
  
  describe "#partialize_url" do
    it {
      u = @op.send(:partialize_url, 'https://example.com')
      u[:scheme].should == 'https'
      u[:authority].should == 'example.com'
      u[:port].should be_empty
      u[:path].should be_empty
    }
    
    it {
      u = @op.send(:partialize_url, 'http://example.com:80/foo')
      u[:scheme].should == 'http'
      u[:authority].should == 'example.com'
      u[:port].should == '80'
      u[:path].should == 'foo'
    }
    
    it {
      u = @op.send(:partialize_url, 'http://*.example.com/foo/bar')
      u[:scheme].should == 'http'
      u[:authority].should == '*.example.com'
      u[:path].should == 'foo/bar'
    }
  end
end