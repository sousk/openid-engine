require 'openid_engine/acts_as_op'
class ServersController < ApplicationController
  include OpenidEngine::ActsAsOp
  
  skip_before_filter :login_required , :only => [:show, :xrds, :create]
  protect_from_forgery :except => [:create, :xrds]
  
  XRDS_TEMPLATE = 'servers/xrds.xml.erb'
  
  def show
    if openid_request?
      openid_authentication
    else
      respond_to do |f|
        f.xrds { render_xrds XRDS_TEMPLATE }
        f.html { render }
      end
    end
  end
  
  def xrds
    respond_to do |f|
      f.xrds {render_xrds XRDS_TEMPLATE}
      f.xml {render :template => XRDS_TEMPLATE, :layout => false, :mime => :xml }
    end
  end
  
  def create
    if openid_request?
      openid_authentication 
    else
    end
  end
  
  private
  def openid_authentication
    $LOGGER = logger
    process_indirect_communication
  end
end
