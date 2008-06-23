require 'openid_engine/acts_as_op'

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include OpenidEngine::ActsAsOp
  
  skip_before_filter :login_required , :only => [:new, :create, :xrds, :show]
  
  def rescue_action(e)
    case e
    when ActiveRecord::RecordNotFound
      render_404
    else
      super
    end
  end
  
  def show
    @requested_user = User.find params[:id]
    respond_to do |f|
      f.xrds { render_xrds 'users/xrds.xml.erb' }
      f.html { render }
    end
  end
  
  def xrds
    @requested_user = User.find params[:id]
    render_xrds('users/xrds.xml.erb')
  end

  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

end
