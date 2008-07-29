module OpenidEngine
  module Message
    module Validator
      
      attr_reader :rules, :errors, :requires
      
      def add_rules(adds)
        (@rules ||= {}).merge!(adds)
      end
      
      def add_requires(*keys)
        @requires = (@requires ||= []) + keys
      end
      
      def errors
        @errors ||= []
      end
      
      def included(*array)
        lambda { |k,v| 
          raise ValidationError, "#{self.class}: #{k}:'#{v}' should be #{array.join(' or ')}" unless array.include?(v) }
      end
      
      def matched(to)
        lambda { |k,v|
          raise ValidationError, "value of #{k} (#{v}) should be matched to '#{to}'" unless v == to }
      end
      
      def less_than(limit)
        lambda { |k, v|
          raise ValidationError, "size of #{k}'s value should be less than #{limit} but #{v.length}" unless v.length <= limit }
      end
      
      def numeric
	      lambda { |k, v|
	        raise ValidationError, "value of #{k} (#{v}) should be numeric" unless v =~ /^\d+$/ }
      end
      
      def validate
        @errors = [] # clear
        if @rules
    	    @rules.each { |key, procs|
    	      if self.has_key? key
      	      value = self[key]
      	      Array(procs).each{ |proc|
                begin
      	          proc.call(key, value)
                rescue ValidationError => e
                  @errors << e.to_s
                end
      	      }
    	      end
    	    }
  	    end
  	    if @requires
  	      @requires.each { |k|
    	      v = self[k]
    	      @errors << "value of #{k} is required but empty or nil" if v.nil? || v.empty?
    	    }
  	    end
      end
      
      def valid?
        @errors.empty?
      end
    end # end Validator
    
    class Base < Hash
      include Validator
      
      def initialize(message)
        add_requires :ns
        add_rules :ns => matched(TYPE[:ns])        
        self[:ns] = TYPE[:ns]
        
        # merge hashes, self and message
        message.each{ |k, v|
          self[k.to_s.gsub(/^openid\./, '').to_sym] = v
        }
        validate
        
        super nil
      end
          
      def to_query
        self.map{ |k,v|
          encoded = v.gsub(/[^\w\.\-]/n) { |ch| '%%%02X' % [ch[0]]} # URL Encode
          "openid.#{k.to_s}=#{encoded}"
        }.join('&')
      end
    end
  end
end