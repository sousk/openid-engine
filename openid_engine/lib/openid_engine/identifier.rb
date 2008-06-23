require "openid_engine"
require "uri"

module OpenidEngine
  module Identifier
    XRI_REGEXP = %r<(xri://)?[=@]>
    URL_REGEXP = %r<^https?://>i
    
    def normalize(str)
      str = str.to_s.chomp
      xri?(str) ? normalize_xri(str) : normalize_uri(str)
    end
    
    def normalize_xri(str)
      str.sub(%r<^xri:\/\/>i, '')
    end
    
    def normalize_uri(str)
      uri = URI.parse str =~ URL_REGEXP ? str : "http://#{str}"
      uri.scheme = uri.scheme.downcase  # URI should do this
      uri.normalize.to_s
    end
  
    def url?(str)
      str =~ URL_REGEXP
    end
  
    def xri?(str)
      str =~ XRI_REGEXP
    end
  end
end
