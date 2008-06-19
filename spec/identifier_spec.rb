# require File.dirname(__FILE__) + '/spec_helper'
# 
# describe OpenidEngine::Identifier do
#   include OpenidEngine::Identifier
#   
#   describe "#normalize" do
#     it "should normalize URL or XRI" do
#       # see Appendix A.1
#       [
#         ['example.com', 'http://example.com/'],
#         ['http://example.com', 'http://example.com/'],
#         ['https://example.com/', 'https://example.com/'],
#         ['http://example.com/user', 'http://example.com/user'],
#         ['http://example.com/user/', 'http://example.com/user/'],
#         ['http://example.com/', 'http://example.com/'],
#         ['=example', '=example'],
#         ['xri://=example', '=example']
#       ].each {|set|
#         from, to = set
#         normalize(from).should == to
#       }
#     end
#   end
# end
