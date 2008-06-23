require File.dirname(__FILE__) + '/spec_helper'

describe 'OpenidEngine' do
  include OpenidEngine
  
  it {
    OpenidEngine::TYPE[:server].should_not be_empty
  }

end
