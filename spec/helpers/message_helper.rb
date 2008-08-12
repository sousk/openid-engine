def mocked_message(name)
  msg = mock name
  msg.stub!(:validate)
  msg.stub!('[]')
  msg.stub!('[]=')
  msg
end
