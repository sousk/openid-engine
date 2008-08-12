# require "openid_engine/dh"
# require "openid_engine/agent"
# require "openid_engine/message/association_request"
# require "openid_engine/message/association_response"
# 
# module OpenidEngine
#   class Association
#     include OpenidEngine
#     
#     DEFAULT_ASSOC_TYPE = 'HMAC-SHA256'
#     DEFAULT_SESSION_TYPE = 'DH-SHA256'
#     
#     def initialize(repository, options={})
#       @repository = repository
#       @assoc_type = options[:assoc_type] || DEFAULT_ASSOC_TYPE
#       @session_type = options[:session_type] || DEFAULT_SESSION_TYPE
#       @agent = OpenidEngine::Agent.new
#     end
#     
#     def find(options)
#       @repository.find :first, options
#     end
#     
#     def request(op_endpoint, mod, gen, digester=nil)
#       dh = OpenidEngine::Dh.new(mod, gen)
#       res = request_to_op(op_endpoint, dh)
#       res[:secret] = dh.extract_enc_mac_key res[:enc_mac_key], res[:dh_server_public]
#       res
#     end
#     
#     def request_to_op(op_endpoint, dh)
#       req = Message::AssociationRequest.init_from_raw({
#         :assoc_type => @assoc_type,
#         :session_type => @session_type,
#         :dh_modulus => dh.mod,
#         :dh_gen => dh.gen,
#         :dh_consumer_public => dh.public_key
#       }).validate
#       raise Error, req.errors unless req.valid?
#       
#       res = OpenidEngine::Message::AssociationResponse.new(
#         @agent.direct(op_endpoint, req)
#       ).validate.to_raw!
#       raise Error, res.errors unless res.valid?
#       
#       res
#     end
#     #     def extract_secret(res, private_key, p)
#     #       dh_server_pub = btwoc_decode Base64.decode64(res[:dh_server_public])
#     #   dh_shared = mod_exp(dh_server_pub, private_key, p)
#     #   enc_mac_key = Base64.decode64(res[:enc_mac_key])
#     #   
#     #   shared = Digest::SHA256.digest(btwoc_encode(dh_shared)) #FIXME
#     #       
#     #   # Bitwise-XOR two equal length strings.
#     #       # Raises an ArgumentError if strings are different length.
#     #       raise ArgumentError, "Can't bitwise-XOR a String with a non-String" unless shared.kind_of? String
#     #       unless enc_mac_key.length == shared.length
#     #         raise ArgumentError, "Can't bitwise-XOR strings of different length, mac_key:#{enc_mac_key.length}, shared:#{shared.length}" 
#     #   end
#     #       
#     #       result = (0..enc_mac_key.length-1).collect { |i| enc_mac_key[i] ^ shared[i] }
#     #       result.pack("C*")
#     # end
#     
#     #     def request_association(endpoint, public_key, options)
#     #   res = @agent.direct endpoint, Message::AssociationRequest.new({
#     #     :assoc_type => options[:assoc_type] || DEFAULT_ASSOC_TYPE,
#     #     :session_type => options[:session_type] || DEFAULT_SESSION_TYPE,
#     #     :dh_modulus => encode_integer(@mod),
#     #     :dh_gen => encode_integer(@gen),
#     #     :dh_consumer_public => encode_integer(public_key)
#     #   })
#     #   OpenidEngine::Message::AssociationResponse.new res
#     # end
#     
#   end
# end
