require 'openid_engine/agent'
require "openid_engine/yadis/document"

module OpenidEngine
  # usage:
  # y = Yadis.initiate('http://yadis_id.example.com/')
  # y = Yadis.new(xrds)
  # y = Yadis.new(Agent.get_xrds('http://resource_descriptor_url.example.com'))
  # y.services # returns array of services
  class Yadis
    
    XRDS_MIME_TYPE = 'application/xrds+xml'
    
    attr_reader :document
    
    def initialize(xrds)
      @document = xrds.kind_of?(Document) ? xrds : Document.new(xrds)
    end
    
    def services
      unless @services
        # make an array of service converted into hash and sort as priority
        non_priored = []
        priored = {} #hash => #priority
        (@document.services.map{ |s| s.to_hash }).each { |s| 
          if s[:priority]
            priored[s] = s[:priority]
          else
            non_priored << s
          end
        }
        sorted_priored = priored.to_a.sort{|a, b| a[1] <=> b[1] }
        services = (sorted_priored.collect{ |service, prior| service }) + non_priored
        @services = services.map{ |s| s.to_hash }
      end
      @services
    end
    
    class << self
      
      # see yadis-v1.0 sec:6.2
      # #initiate execute these 3 processes
      # 1. finding Resource Descriptor URL from given string (yadis_id)
      # 2. fetching XRDS from the RD URL
      # 3. initialize Yadis Obeject with its XRDS and return its yadis object
      def initiate(yadis_id)
        rdurl = id2rd(yadis_id)
        xrds = rd2xrds(rdurl)
        new(xrds)
      end
      
      def agent
        @agent ||= Agent.new
      end
      
      # get Resource Descriptor URL from Yadis ID
      def id2rd(yadis_id)
        # TODO, try anoter request when HEAD resulted in failure
        # r = @agent.head(yadis_id, 'Accept' => XRDS_MIME_TYPE)
        r = agent.get(yadis_id, 'Accept' => XRDS_MIME_TYPE)
        validate_response(r)
        find_rdurl_from_response(r, yadis_id)
      end

      # get XRDS document from Resource Descriptor URL
      def rd2xrds(rdurl)
        r = agent.get_xrds(rdurl)
        validate_response(r)
        Document.new(r.read)
      end
      
      private
      def find_rdurl_from_response(r, requested_url) #FIXME
        case
        # case of 3: no body, only header
        when r.respond_to?(:x_xrds_location) then r.x_xrds_location
        when r.respond_to?(:content_type) && r.content_type == XRDS_MIME_TYPE then requested_url #FIXME
        else
          raise "not implemented yet, #{r.read}, #{r.inspect}, " + r.meta.collect{|k,v| k.to_s + ':' + v.to_s }.join("\n")
        end
      end
      
      def validate_response(r)
        raise Error, "#{r.status.join(': ')}" unless r.status.first == '200'
      end
    end
    class Error < StandardError; end
  end
end
