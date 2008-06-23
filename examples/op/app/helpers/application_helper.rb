# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def op_endpoint_url
    server_url
  end
  
  def local_identifier(user)
    user_url user
  end
end
