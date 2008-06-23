# to be obsoleted, see message.rb

module OpenidEngine
  class Validator
    attr_reader :errors
    
    def initialize
      @errors = ''
    end
    
    def required()
      lambda { |value| !value.empty? }
    end
    
    def included(array)
      # keys.select { |key| RULES[key] }
 #      # request parameter      
 #      rules = {
 #        :ns => required,
 #         :mode => included('error', 'cantel', 'associate', 'id_res', 'setup_needed',
 #          'checkid_immediate', 'checkid_setup', 'check_authentication'),
 #        :assoc_type => required,
 #        :assoc_type => included('HMAC-SHA1', 'HMAC-SHA256')
 #      }
 #      
 #      # diffie-hellman request params
 #      rules.merge!({
 #        :dh_modulus
 #      })
 # M		  
    end
  end
end
