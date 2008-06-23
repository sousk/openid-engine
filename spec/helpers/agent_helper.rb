def mock_response(status, headers={})
  r = mock('Response', :status => [status.to_s, 'hello, hello'], :read => (block_given?)? yield : "")
  headers.each do |msg, value|
    r.stub!(msg).and_return(value)
  end
  r
end

def xrds_mimetype
  'applicatino/xrds+xml'
end