# require File.dirname(__FILE__) + '/spec_helper'
# 
# describe OpenidEngine::Rp do
#   
#   before(:each) do
#     @policy = {
#       :ns => OpenidEngine::TYPE_URI[:auth2p0],
#       :assoc_type => 'HMAC-SHA256',
#       :session_type => 'DH-SHA256'
#     }
#     @rp = OpenidEngine::Rp.new(@policy)
#     @us_identifier = p[:user_supplied_identifier]
#   end
#   
#   # it {
#   #   policy = {
#   #     :ns => OpenidEngine::TYPE_URI[:auth2p0],
#   #     :mode => 'associate',
#   #     :assoc_type => 'HMAC-SHA256',
#   #     :session_type => 'DH-SHA256',
#   #     :identity => 'http://localhost:3000/users/sou',
#   #     :return_to => 'http://localhost:8080/session'
#   #   }
#   #   @rp.get_assoc(policy)
#   # }
# 
#   
#   describe "#new" do
#   end
#   
#   describe "#discover_services" do
#   end
#   
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
