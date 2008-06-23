require "openid_engine/message/base"
require "openid_engine/message/associate"

module OpenidEngine
  module Message
    
    def self.factory(type, params)
      klass = self.const_get type.to_s.split('_').map{|s| s.capitalize!}.join # 'foo_bar' => FooBar
      if klass.nil?
        raise "no message type matched against #{type}" 
      else
        klass.new params
      end
    end    
  end
end
