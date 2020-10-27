class ApplicationController < ActionController::Base
  include DeliveryDateConcerns
  include DiscountConcerns
  include Shipping

  protect_from_forgery with: :exception

  helper :all # include all helpers, all the time

  helper_method(
    :admin?,
    :admin_or_manager?,
    :basket,
    :logged_in?,
    :manager?,
    :website
  )

  before_action(
    :set_time_zone,
    :website,
    :protect_staging_website,
    :initialize_page_defaults,
    :current_user,
    :set_locale,
    :protect_private_website,
    :initialize_tax_display,
    :set_resolver,
    :basket,
    :set_shipping_amount
  )

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_error
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::RoutingError, with: :not_found
    rescue_from ActionController::UnknownController, with: :not_found
  end

  def error
    raise "Intentional error"
  end

  def basket
    @basket ||= find_basket
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user]) || User.new
  end

  def website
    @website ||= find_website
  end

  def logged_in?
    current_user.persisted?
  end

  protected

  def admin?
    logged_in? && current_user.admin?
  end

  def manager?
    logged_in? && (current_user.managed_website == website)
  end

  def admin_or_manager?
    admin?
  end

  def admin_required
    unless admin?
      flash[:notice] = "You need to be logged in as an administrator to do that."
      redirect_to sign_in_path
    end
  end

  def user_required
    unless logged_in?
      flash[:notice] = "You need to be logged in to do that."
      redirect_to sign_in_path
    end
  end

  def admin_or_manager_required
    admin_required
  end

  def set_time_zone
    Time.zone = "London"
  end

  def find_website
    @w = Website.first || Website.new
  end

  def not_found
    render "not_found", formats: [:html], status: 404
  end

  def render_error(exception)
    ExceptionNotifier::Notifier
      .exception_notification(request.env, exception)
      .deliver
    render file: "#{Rails.root}/public/500", layout: false, status: 500
  end

  def initialize_page_defaults
    @blog = nil
    @description = website.name
    @no_follow = nil
    @no_index = nil
    @title = nil
  end

  def protect_private_website
    if website.private? && !logged_in?
      flash[:notice] = "You must be logged in to view this website."
      redirect_to sign_in_path
    end
  end

  def protect_staging_website
    if website.staging_password.present?
      request_http_basic_authentication unless authenticate_with_http_basic { |_u, p| p == website.staging_password }
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
  rescue => err
    logger.error err
    flash.now[:notice] = "#{I18n.locale} translation not available"

    I18n.load_path -= [locale_path]
    I18n.locale = session[:locale] = I18n.default_locale
  end

  def find_basket
    if session[:basket_id]
      @basket = Basket.find_by(id: session[:basket_id])
      @basket if @basket&.can_update?
    else
      @basket = nil
    end || create_basket
  end

  def create_basket
    @basket = Basket.new
    update_basket_details
    session[:basket_id] = @basket.id
    @basket
  end

  # Updates the current basket with details from the user's session.
  def update_basket_details
    basket.update_details(session)
  end

  # Allows the use of a website custom view template resolver to let
  # websites override the base templates with custom ones, either in the
  # database or in the filesystem under the directory
  # +app/views/theme+.
  #
  # Since templates can execute arbitrary Ruby code this should be used in
  # a deployment where only trusted developers can create templates.
  #
  # Adapted from http://www.justinball.com/2011/09/27/customizing-views-for-a-multi-tenant-application-using-ruby-on-rails-custom-resolvers/
  def set_resolver
    return unless website
    if (resolver = website_resolver_for(website))
      resolver.update_website(website)
      prepend_view_path resolver
    end
  end

  @@website_resolver = {}

  def website_resolver_for(website)
    @@website_resolver[website.id] ||= website.build_custom_view_resolver
  end
end
