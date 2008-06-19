require "openid_engine"

module OpenidEngine
  module Identifier
    XRI_REGEXP = %r<(xri://)?[=@]>
    URL_REGEXP = %r<^https?://>
    
    def normalize(str)
      str = str.to_s.chomp
      if xri?(str)
        str.sub(%r<^xri:\/\/>i, '')
      else
        uri = URI.parse(str.to_s.strip)
        uri = URI.parse("http://#{uri}") unless uri.scheme
        uri.scheme = uri.scheme.downcase  # URI should do this
        uri.normalize.to_s
      end
    end
  
    def url?(str)
      str =~ URL_REGEXP
    end
  
    def xri?(str)
      str =~ XRI_REGEXP
    end
  end
end
