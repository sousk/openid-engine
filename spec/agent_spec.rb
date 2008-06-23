# require File.dirname(__FILE__) + '/spec_helper'
# 
# describe OpenidEngine::Agent do
#   before(:each) do
#     @agent = OpenidEngine::Agent.new
#     @url = TEST_PROVIDER
#   end
#   
#   describe "request method" do
#     
#     def should_make_request_by(method)
#       @agent.should_receive(:request).with(method, @url, :accept => 'text/xml').and_return('response')
#       @agent.send(method, @url, :accept => 'text/xml').should == 'response'
#     end
#     
#     it { should_make_request_by(:get) }
#     it { should_make_request_by(:post) }
#     it { should_make_request_by(:head) }
#     
#     it "should make get request with application/xrds+xml in its header" do
#       @agent.should_receive(:request).with(:get, @url, 'Accept' => 'application/xrds+xml').and_return('response')
#       @agent.get_xrds(@url).should == 'response'
#     end
#     
#     it "should send request" do
#       OpenURI.should_receive(:open_uri).with(
#         an_instance_of(URI::HTTP), {'User-Agent' => OpenidEngine::Agent::NAME, :method => :get, 'Accept' => 'text/html'}
#       ).and_return('response')
#       @agent.request(:get, @url, 'Accept' => 'text/html').should == 'response'
#     end
#   end
# end
