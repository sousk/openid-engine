require "openid_engine"
module OpenidEngine::ActsAsOp
  def openid_request?
    params.has_key?('openid.ns') || params.has_key?('openid_identifier')
  end
  
  def process_indirect_communication
    case params['openid.mode']
    when 'checkid_setup' then login_required && process_authentication_request
    when 'associate'     then process_associate_request
    else
      raise "not implemented yet :#{params['openid.mode']}"
    end
  end
  
  def process_authentication_request
    realm, return_to = params['openid.realm'], params['openid.return_to']
    
    assoc = OpenidAssociation.find_by_handle params['openid.assoc_handle']
    raise "assoc missing" unless assoc
    
    # check realm
    if return_to
      pattern = Regexp.new realm.split("*.").map{ |part| Regexp.escape part }.join(".*\.?")
      raise "return_to not matched against realm, return_to:#{return_to}, realm:#{realm}" unless return_to =~ pattern
    end
    
    signing_keys = [:op_endpoint, :return_to, :response_nonce, :assoc_handle, :claimed_id, :identity]
    
    message = {
      :mode => 'id_res',
      :op_endpoint => server_url,
      :claimed_id => user_url(current_user),
      :identity => current_user.id,
      :return_to => params['openid.return_to'],
      :response_nonce => gen_nonce,
      :assoc_handle => assoc.handle,
      :signed => signing_keys.map { |key| key.to_s }.join(',')
    }
    message[:sig] = sign_message assoc, signing_keys, message
    
    indirect_response message
  end
  
  def gen_nonce
    random_string(6, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") + 
      Time.now.getutc.strftime('%Y-%m-%dT%H:%M:%SZ')
  end
  
  def sign_message(assoc, keys, message)
    keyvalues = keys.map{ |key|
       "%s:%s\n" % [key, message[key]]
    }.join
    
    digester = OpenSSL::Digest::SHA256.new
    sig = Base64.encode64(OpenSSL::HMAC.digest(digester, assoc.secret, keyvalues)).chomp
    sig
  end
  
  def process_direct_communication
    case params['openid.mode']
    when 'associate' then process_associate_request
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
  
  def process_associate_request
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
    url = (params['openid.return_to'] || params['openid.realm']) + "?" + fields.map{ |k,v| "openid.#{k}=#{v}" }.join("&")
    redirect_to url
  end
  
  def requested_user
    unless @requested_user
      @requested_user = User.find(params[:id]) or render :text => "requested user not found", :status => 404
    end
    @requested_user
  end
  
  def catch_openid_request
    case params['openid.mode']
    when 'id_setup'
    end
  end
  
end
