require "openid_engine/message/base"

module OpenidEngine
  module Message
    
    def self.factory(type, params)
      # camelize type: 'foo_bar' => FooBar
      klass = self.const_get type.to_s.split('_').map{|s| s.capitalize!}.join 
      if klass.nil?
        raise "no message type matched against #{type}" 
      else
        klass.new params
      end
    end
  end
  
  class ValidationError < StandardError; end
end
