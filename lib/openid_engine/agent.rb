require 'rest-open-uri'

module OpenidEngine
  class Agent
    NAME = 'Ruby-OpenidEngine'
    XRDS_TYPE = 'application/xrds+xml'
      
    # Direct Request specified at 5.1.1
    def direct(endpoint, messages)
      query = to_openid_query(messages)
      
      # begin
        response = post "#{endpoint}?#{query}",
          'Content-Type' => "application/x-www-form-urlencoded",
          :body => query
      # rest-open-uri forbidden http -> https redirect, so interupt manually
      # to be refactored
      # rescue => e
      #   if e.message =~ %r%redirection forbidden.+http://([^\?]+)\?.+ -> https://\1% && endpoint.include?($~[1])
      #     direct endpoint.sub('http', 'https'), messages
      #   else
      #     raise e
      #   end
      # end
      
      # parse response body,
      # see 5.1.2 Direct Response & 4.1.3 Example
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
    
    def to_openid_query(messages)
      messages.map{ |k,v|
        $LOGGER.info "::to_query::#{k} => #{v}"
        v.gsub!(/[^\w\.\-]/n) { |ch| '%%%02X' % [ch[0]]} # URI Encode
        "openid.#{k.to_s}=#{v}"
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
