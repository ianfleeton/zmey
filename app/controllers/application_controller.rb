class ApplicationController < ActionController::Base
  include DeliveryDateConcerns
  include DiscountConcerns
  include RunningInProduction
  include Shipping

  protect_from_forgery with: :exception

  helper :all # include all helpers, all the time

  helper_method(
    :admin?,
    :basket,
    :current_user,
    :logged_in?,
    :unverified_user,
    :website
  )

  before_action(
    :set_time_zone,
    :website,
    :protect_staging_website,
    :initialize_page_defaults,
    :current_user,
    :unverified_user,
    :set_locale,
    :protect_private_website,
    :initialize_vat_display,
    :basket,
    :set_shipping_amount
  )

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_error
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::RoutingError, with: :not_found
    rescue_from AbstractController::ActionNotFound, with: :not_found
  end

  def error
    raise "Intentional error"
  end

  def basket
    @basket ||= find_basket
  end

  def current_user
    @current_user ||= user_from_session || User.temporary
  end

  def unverified_user
    return @unverified_user if @unverified_user
    if (@unverified_user = unverified_user_from_session)
      if @unverified_user.email_verified_at
        @unverified_user = session[:unverified_user_id] = nil
      end
    end
    @unverified_user
  end

  def website
    @website ||= find_website
  end

  def logged_in?
    current_user.persisted?
  end

  protected

  def user_from_session
    user_type_from_session(:user_id)
  end

  def unverified_user_from_session
    User.unverified_user(name: session[:name], email: session[:email]) ||
      user_type_from_session(:unverified_user_id)
  end

  def user_type_from_session(user_key)
    session[user_key] && User.find_by(id: session[user_key])
  end

  def admin_required
    return if administrator_signed_in?
    flash[:notice] = "You need to be logged in as an administrator to do that."
    redirect_to new_administrator_session_path
  end

  def user_required
    return if logged_in?
    flash[:notice] = "You need to be logged in to do that."
    redirect_to sign_in_path
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

  def initialize_vat_display
    @inc_vat = false

    unless website.vat_number.empty?
      @inc_vat = website.show_vat_inclusive_prices
      # override with user's preference
      unless session[:inc_vat].nil?
        @inc_vat = session[:inc_vat]
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

  def reset_customer_session
    %i[
      user_id
      address_id
      basket_id
      billing_address_id
      delivery_address_id
      delivery_date
      delivery_option
      delivery_postcode
      discount_code
      email
      mobile
      name
      order_id
      page_id
      phone
      shipping_class_id
      source
    ].each { |k| session[k] = nil }
    cookies.signed[:order_id] = nil
  end
end
