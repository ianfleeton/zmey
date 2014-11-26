class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  protect_from_forgery

  helper_method :website, :logged_in?, :admin?, :admin_or_manager?, :manager?

  before_action :set_time_zone, :website, :initialize_page_defaults, :current_user,
    :set_locale, :protect_private_website, :initialize_tax_display,
    :set_resolver, :basket

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_error
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::RoutingError, with: :not_found
    rescue_from ActionController::UnknownController, with: :not_found
  end

  def basket
    @basket ||= find_basket
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
    logged_in? and current_user.managed_website == website
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

  def find_website
    @w = Website.first
    if @w
      return @w
    else
      not_found
    end
  end

  def not_found
    render file: "#{Rails.root.to_s}/public/404", formats: [:html], layout: false, status: 404
  end

  def render_error(exception)
    ExceptionNotifier::Notifier
      .exception_notification(request.env, exception)
      .deliver
    render file: "#{Rails.root.to_s}/public/500", layout: false, status: 500
  end

    def initialize_page_defaults
      @blog         = nil
      @description  = website.name
      @no_follow    = nil
      @no_index     = nil
      @title        = nil
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
      else
        @basket = nil
      end || create_basket
    end

    def create_basket
      @basket = Basket.create
      session[:basket_id] = @basket.id
      @basket
    end

    # Allows the use of a website custom view template resolver to let
    # websites override the base templates with custom ones, either in the
    # database or in the filesystem under the directory
    # +app/views/theme_name+.
    #
    # Since templates can execute arbitrary Ruby code this should be used in
    # a deployment where only trusted developers can create templates.
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
