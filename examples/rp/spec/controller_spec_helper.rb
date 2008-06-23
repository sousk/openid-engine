module ControllerSpecHelper
  
  # be sure to do HTTP access after login/logout
  # or you gotta 'Symbol as array index' error
  def login_as(user)
    request.session[:user] = user ? users(user).id : nil
  end
  
  def logout
    request.session[:user] = nil
  end
  
  def access_denied
    response.should_not be_success
  end

  def access_allowed
    response.should be_success
  end
  
end
