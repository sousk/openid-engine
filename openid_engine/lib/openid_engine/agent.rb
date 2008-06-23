require 'rest-open-uri'

module OpenidEngine
  class Agent
    NAME = 'Ruby-OpenidEngine'
    XRDS_TYPE = 'application/xrds+xml'
      
    # Direct Request specified at 5.1.1
    def direct(endpoint, messages)
      query = to_openid_query(messages)
      
      response = post "#{endpoint}?#{query}",
        'Content-Type' => "application/x-www-form-urlencoded",
        :body => query
        
      direct_response_to_hash response
    end
    
    def direct_response_to_hash(response)
      fields = {}
      response.each { |line| 
        k, v = line.split(':', 2)
        fields[k.strip.to_sym] = v.strip if v
      }
      fields
    end
    
    # obsoleted, use Message#to_query
    def to_openid_query(messages)
      messages.map{ |k,v|
        raise "#{k} is nil" if v.nil?
        # $LOGGER.info "::to_query::#{k} => #{v}"
        encoded = v.gsub(/[^\w\.\-]/n) { |ch| '%%%02X' % [ch[0]]} # URL Encode
        "openid.#{k.to_s}=#{encoded}"
      }.join('&')
    end
    
    def get(url, header={})
      request(:get, url, header)
    end
    
    def get_xrds(url, header={})
      request(:get ,url, header.merge({
        'Accept' => XRDS_TYPE
      }))
    end
    
    def post(url, header={})
      request(:post, url, header)
    end
    
    def head(url, header={})
      request(:head, url, header)
    end
    
    def request(method, url, header)
      header[:method] = method
      header['User-Agent'] = NAME
      open(url, header)
    end
  end
end
