require "openid_engine"
module OpenidEngine
  class Op
    include OpenidEngine
    
    FRAGMENT_REGEXP = /(?:\#((?:[-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]]|%[a-fA-F\d]{2})*))/
    PARTIALIZE_REGEXP = %r%(\w+)://([^/:]+):?(\d+)?/?(.*)%
    
    attr_reader :associations
    
    def initialize(options={})
      @associations = options[:assoc_storage]
    end
    
    # see sec 9.2: Realms
    def verify_return_to_against_realm(message)
      realm, rt = partialize_url(message[:realm]), partialize_url(message[:return_to])
      
      [:scheme, :port].each { |key|
        unless realm[key] == rt[key]
          raise Error, "return_to #{key} doesn't match against realm: return_to:#{rt[key]}, realm:#{realm[key]}"
        end
      }
      
      # compare each authority section from the end
      rt_auths = rt[:authority].split('.').reverse
      realm[:authority].split('.').reverse.each_with_index{ |realm_a, i|
        rt_a = rt_auths[i]
        unless realm_a == '*' || realm_a == rt_a
          raise Error, "return_to authority doesn't match against realm: return_to:#{rt[:authority]}, realm:#{realm[:authority]}"
        end
      }
      
      rt_paths = rt[:path].split('/')
      realm[:path].split('/').each_with_index { |realm_path, i|  
        unless realm_path.empty? || realm_path == rt_paths[i]
          raise Error, "return_to path not matched against realm, return_to:#{rt[:path]}, realm:#{realm[:path]}"
        end
      }
    end
    
    private
    def partialize_url(url)
      PARTIALIZE_REGEXP =~ url
      m = Regexp.last_match
      {
        :scheme => m[1].to_s,
        :authority => m[2].to_s,
        :port => m[3].to_s,
        :path => m[4].to_s
      }
    end
  end
end
