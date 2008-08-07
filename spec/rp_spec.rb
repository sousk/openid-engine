require File.dirname(__FILE__) + '/helpers/rp_helper'

describe OpenidEngine::Rp do
  
  before(:each) do
    mock_agent
    @rp = OpenidEngine::Rp.new
    @supplied_id = PARAMS[:supplied_identity]
    @type = OpenidEngine::TYPE
    @idsel = @type[:identifier_select]
    @return_to = 'http://example.com/return_to'
  end
  
  describe "#request_association" do
    before(:each) do
      @op_endpoint = 'http://op.example.com/'
    end
    
    it "should get association" do
      @agent.should_receive(:direct).and_return({
        :assoc_handle => '{HMAC-SHA256}{48112eb6}{ZjnVgQ==}',
        :assoc_type => 'HMAC-SHA256',
        :dh_server_public => 'FrHWmH/h0E42YFFwmBY8D5yGEpd6vWuRXh4UxEM1TRmkk7hyyS166jF20yylzSUmjozR/UrH7viMobliwOaZv6AnGOHj79tCXjC64z9HhUQOb0+6j1J7z7Bk5Sg7Ea7cyrRT7I+JIn7MGQmBhjezWA7fU3ESVzJ/uNv7pksw9IA=',
        :enc_mac_key => '84sVeyeqscGEbOWOhmZphWuUILn8IUTSUv0POxkE8fw=',
        :expires_in => '1209600',
        :ns => 'http://specs.openid.net/auth/2.0',
        :session_type => 'DH-SHA256'
      })
      
      assoc = @rp.request_association @op_endpoint
      assoc.should have_key(:secret)
      assoc.should have_key(:enc_mac_key)
    end
  end
  
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
