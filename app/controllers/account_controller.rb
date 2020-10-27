# frozen_string_literal: true

# Controller for handling user accounts.
class AccountController < ApplicationController
  include UserAuthenticated

  before_action(
    :set_user,
    only: %i[index edit update change_password update_password]
  )

  def index
  end

  def new
    @no_index = true
    redirect_to(account_path) && return if logged_in?
    session[:source] = "account/new"
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @current_user = @user
      change_user

      # Don't sign in as current user though; tag as unverified instead.
      session[:user_id] = nil
      session[:unverified_user_id] = @user.id

      flash[:notice] = I18n.t("controllers.account.create.created")
      UserNotifier.email_verification(website, @user).deliver_later
      if session[:source] == "checkout/details"
        redirect_to checkout_details_path
      else
        redirect_to_safe_path(root_path)
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    @user.update_explicit_opt_in(params[:explicit_opt_in] == "1")

    if @user.update(user_params)
      flash[:notice] = I18n.t("controllers.account.update.updated")
      redirect_to account_path
    else
      render :edit
    end
  end

  def change_password
  end

  def update_password
    if valid_password_supplied?
      @user.password = params[:password]
      if @user.save
        flash[:notice] = I18n.t("controllers.account.update_password.changed")
        UserNotifier.password_changed(website, @user).deliver_later
        redirect_to account_path
        return
      else
        flash[:notice] = I18n.t("controllers.account.update_password.invalid")
      end
    end
    render :change_password
  end

  def set_unverified_password
    if unverified_user && !unverified_user.password_set?
      unverified_user.password = params[:password]
      if unverified_user.save
        send_verification_email(unverified_user)
        flash[:notice] = "We've created your account! Check your email for your verification link."
        redirect_back(fallback_location: root_path)
        return
      end
    end
    flash[:alert] = "Could not create account. Please check that your password is at least 8 characters long."
    redirect_back(fallback_location: root_path)
  end

  def valid_password_supplied?
    params[:password].present? &&
      params[:password] == params[:password_confirmation]
  end

  def verify_email
    user = User.find_by(id: params[:id])
    if user.nil? || user.email_verification_token != params[:t]
      flash[:notice] = I18n.t("controllers.account.verify_email.invalid_link")
      redirect_to account_verify_email_new_path
      return
    end

    user.email_verified_at = Time.current
    user.save
    session[:user_id] = user.id
    flash[:notice] = I18n.t("controllers.account.verify_email.verified")
    redirect_to session[:source] == "checkout/details" ? checkout_details_path : root_path
  end

  def verify_email_new
  end

  def verify_email_send
    if (unverified_user = User.find_by(email: params[:email]))
      session[:unverified_user_id] = unverified_user.id
      flash[:notice] = I18n.t("controllers.account.verify_email_send.sent")

      send_verification_email(unverified_user)

      redirect_to account_verify_email_new_path
    else
      flash[:notice] = I18n.t(
        "controllers.account.verify_email_send.unrecognised"
      )
      redirect_to account_new_path
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :email, :name, :opt_in, :password, :password_confirmation
    )
  end

  def send_verification_email(unverified_user)
    if unverified_user.email_verification_token.blank?
      unverified_user.set_email_verification_token
      unverified_user.save
    end

    UserNotifier.email_verification(website, unverified_user).deliver_later
  end
end
