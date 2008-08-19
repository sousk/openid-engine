require "openid_engine/rp"
require "openid_engine/associatable"

module OpenidEngine::ActsAsRp

  include OpenidEngine
  include OpenidEngine::Identifier
  
  def self.included(base)
    OpenidAssociation.class_eval("include OpenidEngine::Associatable")
  end
  
  def log(msg)
    logger.info msg
  end
  
  def openid_request?
    params.has_key?('openid.ns') || params.has_key?('openid_identifier')
  end
  
  def process_openid_request(options)
    case
    when params[:openid_identifier] then log('start auth'); start_openid_authentication(options)
    when params['openid.mode'] == 'id_res' then log('process assertion'); process_assertion
    else
      log("no mode available #{params['openid.mode']}")
    end
  end
  
  def rp
    @rp ||= Rp.new
  end
  
  def openid_identifier
    normalize params[:openid_identifier]
  end
  
  def start_openid_authentication(options={})
    rp.discover(openid_identifier) do |service|
      if service[:type].include? TYPE[:server]
        assoc = get_association service[:uri]
        if assoc
          msg = Message::CheckidRequest.new({
            :claimed_id => TYPE[:identifier_select],
            :identity => TYPE[:identifier_select],
            :assoc_handle => assoc.handle,
            :return_to => options[:return_to]
          })
          
          session[:last_requested_endpoint] = service[:uri]
          redirect_to service[:uri] + '?' + msg.to_query
        end
      end
    end
    log "no information available against '#{openid_identifier}'"
  end
  
  def retrieve_association(option)
    col, value = option.to_a.flatten
    assoc = OpenidAssociation.send("find_by_#{col}", value)
    raise Error, "assoc missing #{assoc}" unless assoc
    raise Error, "assoc expired" if assoc && assoc.expired?
    assoc
  end
  
  def get_association(op_endpoint)
    begin
      assoc = retrieve_association :op_endpoint => op_endpoint
    rescue Error => e
      log "#{e}, try to get new assoc"
      assoc = OpenidAssociation.request op_endpoint
      assoc.save
    end
    assoc
  end
  
  def process_assertion
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
    begin
      assoc = retrieve_association :handle => params['openid.assoc_handle']
    rescue Error => e
      raise "#{e}, handle::#{params['openid.assoc_handle']}::, not implemented yet (assoc missing)"
    end
    
    op_sig = params['openid.sig']
    
    # generate signature
    keyvalues = params['openid.signed'].split(',').collect { |key| 
      "%s:%s\n" % [key, params["openid.#{key}"]]
    }.join    
    digester = assoc.encryption_type == 'HMAC-SHA1' ? OpenSSL::Digest::SHA1.new : OpenSSL::Digest::SHA256.new
    sig = Base64.encode64(OpenSSL::HMAC.digest(digester, assoc.secret, keyvalues)).chomp
    
    raise "openid.sig not matched, rp::#{sig}::, op::#{op_sig}" unless sig == op_sig
  end
end
