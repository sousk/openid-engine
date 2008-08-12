module OpenidEngine
  module Message
    
    def self.factory(subklass, params)
      require "openid_engine/message/#{subklass}"
      
      # camelize type: 'foo_bar' => FooBar
      klass = self.const_get subklass.to_s.split('_').map{|s| s.capitalize!}.join
      klass.new params
    end
  end
  
  class ValidationError < StandardError; end
end
