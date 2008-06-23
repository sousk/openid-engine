require "base64"

class OpenidAssociation < ActiveRecord::Base
  class << self
    def new_from_response(endpoint, response)
      new :op_endpoint => endpoint,
        :handle => response[:assoc_handle],
        :encryption_type => response[:assoc_type],
        :secret => response[:secret],
        :expiration => Time.now.utc + response[:expires_in].to_i
    end
  end
end
