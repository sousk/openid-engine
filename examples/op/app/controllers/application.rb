# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'default'
  helper :all # include all helpers, all the time
  
  include AuthenticatedSystem
  
  before_filter :login_required, :log_parameters  
  

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'afe3207c2b779a9ae810f8a38926369f'

  private
  def render_xrds(template)
    do_render = lambda { |mime| 
      render :template => template, :mime_type => mime, :layout => false
    }
    respond_to do |f|
      f.xrds { do_render.call Mime::Type.lookup_by_extension('xrds') }
      f.all  { do_render.call(:xml) }
    end
  end
  
  def render_404 
    respond_to do |f|
      f.html { render :text => "not found", :status => 404 } #:file => "#{RAILS_ROOT}/public/.html", :status => ' Not Found' } 
      f.all  { render :nothing => true, :status => 404 }
    end
  end
  
  def log_parameters
    logger.info "--"
    request.env.each do |k, v|
      logger.info "#{k}::#{v}"
    end
    logger.info "--"
  end
end
