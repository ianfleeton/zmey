class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :website, :logged_in?, :admin?, :admin_or_manager?, :manager?

  before_action :set_time_zone, :website, :initialize_meta_tags, :current_user,
    :set_locale, :protect_private_website, :initialize_tax_display,
    :set_resolver, :find_basket

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_error
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::RoutingError, with: :not_found
    rescue_from ActionController::UnknownController, with: :not_found
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user])
  end

  def website
    @website ||= find_website
  end

  protected

  def logged_in?
    current_user.is_a?(User)
  end

  def admin?
    logged_in? and current_user.admin?
  end

  def manager?
    logged_in? and current_user.managed_website == @w
  end

  def admin_or_manager?
    admin? or manager?
  end

  def admin_required
    unless admin?
      flash[:notice] = 'You need to be logged in as an administrator to do that.'
      redirect_to sign_in_path
    end
  end

  def user_required
    unless logged_in?
      flash[:notice] = 'You need to be logged in to do that.'
      redirect_to sign_in_path
    end
  end

  def admin_or_manager_required
    unless admin_or_manager?
      flash[:notice] = 'You need to be logged in as an administrator or manager to do that.'
      redirect_to sign_in_path
    end
  end

  def set_time_zone
    Time.zone = 'London'
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

  def find_website
    @w = Website.for(request.host, request.subdomains) || Website.first
    if @w
      if request.host == @w.domain
        set_cookie_domain(@w.domain)
      end
      return @w
    else
      not_found
    end
  end

  def not_found
    render "#{Rails.root.to_s}/public/404", formats: [:html], layout: false, status: 404
  end

  def render_error(exception)
    ExceptionNotifier::Notifier
      .exception_notification(request.env, exception)
      .deliver
    render "#{Rails.root.to_s}/public/500", layout: false, status: 500
  end

  def initialize_meta_tags
    @description = website.name
  end

  def protect_private_website
    if website.private? && !logged_in?
      flash[:notice] = 'You must be logged in to view this website.'
      redirect_to sign_in_path
    end
  end

  def initialize_tax_display
    @inc_tax = false

    unless website.vat_number.empty?
      @inc_tax = website.show_vat_inclusive_prices
      # override with user's preference
      unless session[:inc_tax].nil?
        @inc_tax = session[:inc_tax]
      end
    end
  end

  def set_locale
    session[:locale] = params[:locale] if params[:locale]
    I18n.locale = session[:locale] || website.default_locale

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

    def find_basket
      if session[:basket_id]
        @basket = Basket.find_by(id: session[:basket_id])
        create_basket if @basket.nil?
      else
        create_basket
      end
    end

    def create_basket
      @basket = Basket.new
      @basket.save
      session[:basket_id] = @basket.id
    end

    # Allows the use of a website custom view template resolver to let
    # websites override the base templates with custom ones, either in the
    # database or in the filesystem under the directory specified in
    # +ENV['ZMEY_THEMES']/app/views+.
    #
    # Since templates can execute arbitrary Ruby code this should be used in
    # a deployment where:
    #
    # 1. Only trusted developers can create templates, or
    # 2. There are no other tenants.
    #
    # Adapted from http://www.justinball.com/2011/09/27/customizing-views-for-a-multi-tenant-application-using-ruby-on-rails-custom-resolvers/
    def set_resolver
      return unless website
      if resolver = website_resolver_for(website)
        resolver.update_website(website)
        prepend_view_path resolver
      end
    end

    @@website_resolver = {}

    def website_resolver_for(website)
      @@website_resolver[website.id] ||= website.build_custom_view_resolver
    end
end
