require File.dirname(__FILE__) + '/helpers/rp_helper'

describe OpenidEngine::Rp do
  
  before(:each) do
    @rp = OpenidEngine::Rp.new
    @supplied_id = PARAMS[:supplied_identity]
    @type = OpenidEngine::TYPE
    @idsel = @type[:identifier_select]
    @return_to = 'http://example.com/return_to'
  end
  
  # describe "#new" do
  #   it "should accept user defined policy" do
  #     rp = OpenidEngine::Rp.new :foo => 'foo'
  #     policy = rp.instance_variable_get('@policy')
  #     policy[:foo].should == 'foo'
  #   end
  # end
  
  # describe "#make_query" do
  #   it "should make checkid_setup request params" do
  #     params = @rp.make_query :checkid_request, 
  #       :identity => @idsel, :claimed_id => @idsel, :assoc_handle => 'handle', :return_to => @return_to
  #     
  #     {
  #       :mode => 'checkid_setup', 
  #       :ns => @type[:ns], 
  #       :identity => @type[:identifier_select], 
  #       :claimed_id => @type[:identifier_select]
  #     }.each { |key, value|  
  #       params[key].should == value
  #     }
  #   end
  # end
  
  describe "#verify_return_to" do
    def do_verify(return_to)
      @rp.verify_return_to return_to, 'http://hoge.example.com/foo/bar'
    end
    
    it "should return nothing with valid params" do
      lambda {
        do_verify('http://hoge.example.com/foo/bar')
      }.should_not raise_error
    end
    
    it "should raise error with invalid params" do
      %w(http://huni.example.com/foo/bar http://hoge.example.com/foo http://hoge.example.com/foo/bar?1).each { |url|
        lambda {
          do_verify url
        }.should raise_error(OpenidEngine::Error)
      }
    end
  end

  describe "#discover" do
    it "should call given block when service discovered" do
      @rp.should_receive(:discover_by_yadis).with(@supplied_id).and_return([SERVICE_SERVER])
      block = lambda { raise "block invoked" }
      lambda { 
        @rp.discover(@supplied_id, &block)
      }.should raise_error("block invoked")
    end
    
    it "should assign hashed-service as argument for given block" do
      @rp.stub!(:discover_by_test).and_return(XRDSDATA[:hashed_services])
      @rp.discover(@supplied_id, :test) do |service|
        service.should be_kind_of(Hash)
        service[:type].should be_kind_of(Array)
      end
    end

    it "should invoke #discover_by_yadis" do
      @rp.should_receive(:discover_by_yadis).with(@supplied_id).and_return([])
      @rp.discover(@supplied_id)
    end
  end
  
  describe "#discover_by_yadis" do
    it {
      mock_yadis_discovery
      @rp.discover_by_yadis(@supplied_identity).should be_kind_of(Array)
    }
  end
end
#   # describe "#start" do
#   #   before(:each) do
#   #   end
#   #   
#   #   it {
#   #     @rp.should_receive(:normalize).and_return(@us_identifier)
#   #     @rp.should_receive(:discover_services).and_return({})
#   #     @rp.start(@us_identifier)
#   #   }
#   # end
#   
#   describe "#discover_services" do
#     describe "when success" do
#       before(:each) do
#         mock_yadis_discovery
#       end
#       
#       it "should return an array of hashed services when success" do
#         @rp.discover_services(@us_identifier).should be_kind_of(Array)
#       end
#     end
#     
#     # it "should try XRI based discovery when the identier is XRI" do
#     #   @id.should_receive(:xri?).and_return(true)
#     #   @rp.should_receive(:discover_by_xri)
#     #   @rp.discovery(@id)
#     # end
#     # 
#     # it "should try Yadis protocol discovery when the identier is not xri (url)" do
#     #   @id.should_receive(:xri?).and_return(false)
#     #   @rp.should_receive(:discover_by_yadis)
#     #   @rp.discovery(@id)
#     # end
#     # 
#     # it "should try HTML based discovery when xrds discovery failed" do
#     #   @id.should_receive(:xri?).and_return(true)
#     #   @rp.should_receive(:discover_by_xri).and_return(nil)
#     #   @rp.should_receive(:discover_from_html)
#     #   @rp.discovery(@id)
#     # end
#   end
# end
