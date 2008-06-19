require "openid_engine/rp"

module OpenidEngine::ActsAsRp
  include OpenidEngine
  
  private
  def openid_request?
    params['openid.ns']
  end
  
  def process_openid_request
    case
    when params[:openid_identifier]        then start_openid_authentication
    when params['openid.mode'] == 'id_res' then complete_openid_authentication
    end
  end
  
end
