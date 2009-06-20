# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  protected

  def set_cookie_domain(domain)
    cookies = session.instance_eval("@dbprot")
    unless cookies.blank?
      cookies.each do |cookie|
        options = cookie.instance_eval("@cookie_options")
        options["domain"] = domain unless options.blank?
      end
    end
  end

  def require_website
    @w = Website.for(request.host, request.subdomains)
    if @w
      if request.host == @w.domain
        set_cookie_domain(@w.domain)
      end
    else
      redirect_to "http://#{MAIN_HOST}:#{request.port}"
    end
  end
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
