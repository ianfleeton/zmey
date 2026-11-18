class CustomerSessionsController < ApplicationController
  include FormRateLimiting
  include UserAuthenticated

  limit_submissions only: :create, to: 10, within: 5.minutes, per_email: :email

  before_action :admin_required, only: [:switch_user]

  def new
    @no_index = true
    redirect_to(account_path) && return if logged_in?
    set_unsafe_redirect_url
  end

  def create
    @current_user = User.authenticate_by(email: params[:email].to_s, password: params[:password].to_s)
    if @current_user
      user_authenticated
    else
      flash[:notice] = "No user was found with this email/password"
      redirect_to after_failed_sign_in_path
    end
  end

  def after_failed_sign_in_path
    if account_password_unset?
      if account_created_before_new_system_launch?
        password_reset_customer_sessions_path(email: params[:email])
      else
        password_set_customer_sessions_path(email: params[:email])
      end
    elsif session[:source] == "checkout/details"
      checkout_details_path
    else
      try_again_path
    end
  end

  def try_again_path
    path = {action: "new"}
    if params[:unsafe_redirect_url].present?
      path["unsafe_redirect_url"] = params[:unsafe_redirect_url]
    end
    path
  end

  # Returns truthy if the customer has attempted to login to an account which
  # has an unset password, such as during automatic account creation.
  def account_password_unset?
    User.exists?(email: params[:email], password_digest: nil)
  end

  def account_created_before_new_system_launch?
    epoch = Date.new(2016, 8, 19).in_time_zone
    User.where(email: params["email"]).pluck(:created_at).first < epoch
  end

  # Ends the current session.
  #
  # If +redirect_to+ param is set then the user is redirected to this URL,
  # otherwise the user is redirected back to the sign in page.
  def destroy
    reset_customer_session
    flash[:notice] = "Logged out successfully"
    redirect_to params[:redirect_to] || {action: "new"}
  end

  # Ends the current session using the HTTP GET method.
  #
  # This can be used for troubleshooting when a user is not signed in but needs
  # to clear their session.
  alias_method :reset, :destroy

  def switch_user
    @current_user = User.find(params[:user_id])
    set_user
  end

  private

  def set_unsafe_redirect_url
    @unsafe_redirect_url = if params[:unsafe_redirect_url].present?
      params[:unsafe_redirect_url]
    else
      request.referer
    end
  end
end
