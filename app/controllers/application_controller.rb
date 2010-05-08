# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  helper_method :logged_in?, :admin?, :admin_or_manager?, :manager?

  before_filter :set_timezone, :require_website, :initialize_user, :set_locale, :protect_private_website, :initialize_tax_display
  
  protected

  def logged_in?
    @current_user.is_a?(User)
  end

  def admin?
    logged_in? and @current_user.admin
  end
  
  def manager?
    logged_in? and @current_user.managed_website == @w
  end
  
  def admin_or_manager?
    admin? or manager?
  end

  def admin_required
    unless admin?
      flash[:notice] = 'You need to be logged in as an administrator to do that.'
      redirect_to :controller => 'sessions', :action => 'new'
    end
  end
  
  def user_required
    unless logged_in?
      flash[:notice] = 'You need to be logged in to do that.'
      redirect_to :controller => 'sessions', :action => 'new'
    end
  end

  def admin_or_manager_required
    unless admin_or_manager?
      flash[:notice] = 'You need to be logged in as an administrator or manager to do that.'
      redirect_to :controller => 'sessions', :action => 'new'
    end
  end

  def set_timezone
    Time.zone = 'London'
  end

  # setup user info on each page
  def initialize_user
    @current_user = User.find_by_id(session[:user])
  end

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
      render :template => "public/404.html", :layout => false, :status => 404
    end
  end
  
  def protect_private_website
    if @w.private? && !logged_in?
      flash[:notice] = 'You must be logged in to view this website.'
      redirect_to :controller => 'sessions', :action => 'new'
    end
  end

  def initialize_tax_display
    @inc_tax = false

    unless @w.vat_number.empty?
      @inc_tax = @w.show_vat_inclusive_prices
      # override with user's preference
      unless session[:inc_tax].nil?
        @inc_tax = session[:inc_tax]
      end
    end
  end

  def set_locale
    session[:locale] = params[:locale] if params[:locale]
    I18n.locale = session[:locale] || @w.default_locale

    locale_path = "#{LOCALES_DIRECTORY}#{I18n.locale}.yml"

    unless I18n.load_path.include? locale_path
      I18n.load_path << locale_path
      I18n.backend.send(:init_translations)
    end

  rescue Exception => err
    logger.error err
    flash.now[:notice] = "#{I18n.locale} translation not available"

    I18n.load_path -= [locale_path]
    I18n.locale = session[:locale] = I18n.default_locale
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
