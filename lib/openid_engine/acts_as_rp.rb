require "openid_engine/rp"

module OpenidEngine::ActsAsRp

  include OpenidEngine
  include OpenidEngine::Identifier
  
  def openid_request?
    params.has_key?('openid.ns') || params.has_key?('openid_identifier')
  end
  
  def process_openid_request(config)
    case
    when params[:openid_identifier] then start_openid_authentication(config)
    when params['openid.mode'] == 'id_res' then complete_openid_authentication
    end
  end
  
  def rp
    @rp ||= Rp.new
  end
  
  def openid_identifier
    normalize params[:openid_identifier]
  end
  
  def start_openid_authentication(config={})
    rp.discover(openid_identifier) do |service|
      if service[:type].include? TYPE[:server]
        assoc = get_association(service[:uri])
        if assoc
          session[:last_requested_endpoint] = service[:uri]
          msg = Message.factory :checkid_request, {
            :claimed_id => TYPE[:identifier_select],
            :identity => TYPE[:identifier_select],
            :assoc_handle => assoc.handle
          }.merge(config)
          
          openid_req = service[:uri] + '?' + msg.to_query
          redirect_to(openid_req)
        end
      end
    end
    # no information available
  end
  
  def get_association(endpoint)
    assoc = OpenidAssociation.find_by_op_endpoint(endpoint, :conditions => ["expiration > ?", Time.now.utc])
    unless assoc
      assoc_response = rp.request_association(endpoint)
      if assoc_response
        assoc = OpenidAssociation.new_from_response(endpoint, assoc_response)
        assoc.save
      end
    end
    assoc
  end
  
  def complete_openid_authentication
    raise "authorized" if verify_openid_response
  end
  
  def verify_openid_response
    # rp.verify_return_to(params['openid.return_to'], request.url)
    verify_return_url
    verify_discovered_information if rp.url?(params['openid.claimed_id'])
    check_nonce
    verify_signatures
    true
  end
  
  def verify_discovered_information
    cid, endpoint = params['openid.claimed_id'], params['openid.endpoint']
    rp.discover_by_yadis(cid).each do |service|
      if service[:type].include? 'http://specs.openid.net/auth/2.0/signon'
        if endpoint
          raise service[:uri].to_s
          next unless service[:uri] == endpoint || (service[:uri].respond_to?(:include?) && service[:uri].include?(endpoint))
        end
        return
      end
    end
    raise "there's no discovered information associated with this claimed ID (#{cid})"
  end
  
  def verify_return_url
    u = URI.parse params['openid.return_to']
    [
      [:scheme, request.protocol.chomp('://')],
      [:host, request.host],
      [:port, request.port],
      [:path, request.path],
    ].each { |part, expectation|
      value = u.send(part)
      unless value == expectation
        raise "#{part} of return_to value should be '#{expectation}' but got '#{value}'"
      end
    }
    if u.query
      u.query.split('&').map{ |q| q.split('=')}.each { |key, value|
        expectation = params[key]
        unless value == expectation
          raise "return to query has invalid value. #{key} should be #{expectation} but is #{value}"
        end
      }
    end
  end
  
  def check_nonce
    endpoint = session[:last_requested_endpoint]
    raise "invalid endpoint" unless endpoint
    nonce = params['openid.response_nonce']
    raise "nonce is already used" if OpenidNonce.find_by_op_endpoint_and_nonce(endpoint, nonce)
    
    OpenidNonce.new(:op_endpoint => endpoint, :nonce => nonce).save
  end
  
  def verify_signatures
    assoc = OpenidAssociation.find_by_handle params['openid.assoc_handle']
    unless assoc
      raise "not implemented yet"
    end
    
    # generate signature
    keyvalues = params['openid.signed'].split(',').collect { |key| 
       "%s:%s\n" % [key, params["openid.#{key}"]]
    }.join
    
    op_sig = params['openid.sig']
    digester = OpenSSL::Digest::SHA256.new
    sig = Base64.encode64(OpenSSL::HMAC.digest(digester, assoc.secret, keyvalues)).chomp
    raise "openid.sig not matched, rp::#{sig}::, op::#{op_sig}" unless sig == op_sig.gsub(/\s/, '+') #FIXME rails bug?
  end
end
