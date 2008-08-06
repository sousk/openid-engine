require "openid_engine"
require "uri"

module OpenidEngine::ActsAsOp
  include OpenidEngine
  
  def openid_request?
    params.has_key?('openid.ns') || params.has_key?('openid_identifier')
  end
  
  def op
    @op ||= OpenidEngine::Op.new(:assoc_storage => OpenidAssociation)
  end
  
  def process_indirect_communication
    case params['openid.mode']
    when 'checkid_setup' then login_required && process_checkid_request
    when 'associate'     then process_association_request
    else
      raise "not implemented yet :#{params['openid.mode']}"
    end
  end
  
  # TODO: support negative assertion
  # TODO: support checkid_immediate mode
  # TODO: support stateless mode (or determine to do not)
  def process_checkid_request
    req = OpenidEngine::Message.factory(:checkid_request, params)
    
    if req[:return_to]
      op.verify_return_to_against_realm req
    end
    
    assoc = op.association.find_by_handle req[:assoc_handle]
    raise "assoc missing" unless assoc
    raise "assoc expired" if assoc.expired?
    
    res = OpenidEngine::Message::PositiveAssertion.new({
      :op_endpoint => server_url,
      :claimed_id => user_url(current_user),
      :identity => current_user.id,
      :return_to => req[:return_to],
      :response_nonce => op.make_nonce,
      :assoc_handle => assoc.handle
    })
    res.sign! assoc
    
    indirect_response res
  end
    
  def process_direct_communication
    case params['openid.mode']
    when 'associate' then process_association_request
    end
  end
  
  def random_string(length, chars=nil)
    s = ""
    if chars
      length.times { s << chars[rand(chars.length)] }
    else
      length.times { s << rand(256).chr }
    end
    s
  end
  
  def process_association_request_new
    req = Message::AssociationRequest.new params
    
    # assoc = op.association.create
  end
  
  def process_association_request
    #TODO validate parameter
    #TODO check session_type, assoc_type that rp requested are both available or not
    
    # extract param
    assoc_type, session_type, mod, gen = 
      params['openid.assoc_type'], params['openid.session_type'], decode_integer(params['openid.dh_modulus']), decode_integer(params['openid.dh_gen'])
    
    # create assoct
    secret = gen_secret
    handle = '{%s}{%x}{%s}' % [assoc_type, Time.now.to_i, Base64.encode64(random_string(4)).chomp]
    assoc = OpenidAssociation.new({
      :handle => handle,
      :encryption_type => assoc_type,
      :lifetime => 3, #60 * 60 * 24 * 7, #sec
      :secret => secret
    })
    
    consumer_public = decode_integer params['openid.dh_consumer_public']
    server_private = gen_private_key(mod)
    enc_mac_key = gen_enc_mac_key(consumer_public, server_private, secret, mod)
    server_public = gen_public_key(server_private, gen, mod)
    
    if assoc.save
      response = {
        :assoc_handle => assoc.handle, 
        :assoc_type => assoc.encryption_type, 
        :session_type => session_type,
        :expires_in => assoc.lifetime,
        :dh_server_public => encode_integer(server_public), 
        :enc_mac_key => Base64.encode64(enc_mac_key).chomp
      }
      response.each { |k,v| logger.info "::assoc-response:: #{k} => #{v}" }
      direct_response response
    else
      raise "not implemented yet"
    end
  end
  
  def gen_secret
    random_string(32) # TODO
  end
  
  def gen_private_key(mod)
	  1 + rand(mod - 2)
	end
	
  def gen_enc_mac_key(consumer_public, pkey, secret, mod)
    dh_shared = mod_exp(consumer_public, pkey, mod)
    hashed_shared = Digest::SHA256.digest(btwoc_encode(dh_shared))
    strxor secret, hashed_shared
  end
  
  def strxor(s, t)
    result = (0..s.length-1).collect { |i| (s[i] ^ t[i]).chr }
    result.join
  end
  
  # 8.2.3, base64(btwoc(g ^ xb mod p))
  # xb is OP's private key
  def gen_public_key(private_key, gen, mod)
	  mod_exp(gen, private_key, mod)
	end
	def mod_exp(p, n, q)
		n_p = n     # N 
		y_p = 1     # Y
		z_p = p  # Z
		while n_p != 0
		  if n_p[0] == 1
		    y_p = (y_p*z_p) % q
      end
  		n_p = n_p >> 1  
      z_p = (z_p * z_p) % q
    end
    y_p
	end
  
  
  def decode_integer(enc)
    btwoc_decode Base64.decode64(enc)
  end
  
  def btwoc_decode(s)
		s = "\000" * (4 - s.size % 4) + s
		n = 0
  	s.unpack('N*').each { |x|
		  n <<= 32
  		n |= x
  	}
  	n
  end
  def btwoc_encode(int)
    bits = int.to_s(2)
		pad = (8 - bits.size % 8) || (bits[0,1] == '1' ? 8 : 0)
		bits = ('0' * pad) + bits if pad
		[bits].pack('B*')
  end
  def encode_integer(int)
    Base64.encode64(btwoc_encode(int)).delete("\n")
  end
  
  
  def direct_response(fields={})
    # TODO validate field parameters
    fields[:ns] = 'http://specs.openid.net/auth/2.0' unless fields[:ns]
    render :text => fields.map{|k,v| "#{k}:#{v}\n"}.join
  end
  
  def indirect_response(fields={})
    # TODO validate field parameters
    fields[:ns] = 'http://specs.openid.net/auth/2.0' unless fields[:ns]
    #TODO, validation
    url = (params['openid.return_to'] || params['openid.realm']) + "?" + fields.map{ |k,v| "openid.#{k}=#{url_encode(v)}" }.join("&")
    redirect_to url
  end
end
