class UsersController < ApplicationController
  before_action :find_user, except: [:new, :create, :forgot_password, :forgot_password_send]
  before_action :admin_or_manager_or_same_user_required, only: [:show, :edit, :update]
  before_action :can_users_create_accounts, only: [:new, :create]

  skip_before_action :protect_private_website, only: [
    :forgot_password, :forgot_password_send,
    :forgot_password_new, :forgot_password_change
  ]

  def show
    @title = "Your Account"
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      if admin_or_manager?
        flash[:notice] = "New user account has been created."
        redirect_to admin_users_path
      else
        @current_user = @user
        session[:user] = @user.id
        flash[:notice] = "Your account has been created."
        redirect_to @user
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    # only administrators can update protected attributes
    if admin?
      @user.admin = params[:user][:admin]
      @user.manages_website_id = params[:user][:manages_website_id]
    end

    params[:user].delete(:admin)
    params[:user].delete(:manages_website_id)

    if @user.update_attributes(user_params)
      flash[:notice] = "User successfully updated."
      redirect_to @user
    else
      render :edit
    end
  end

  def forgot_password
  end

  def forgot_password_send
    @user = User.find_by(email: params[:email])
    if @user.nil?
      flash[:notice] = "There is no user registered with that email address"
      redirect_to action: "forgot_password"
    else
      @user.forgot_password_token = User.generate_forgot_password_token
      @user.save
      UserNotifier.token(@w, @user).deliver_now
    end
  end

  def forgot_password_new
    forgot_password_params_ok?
  end

  def forgot_password_change
    if forgot_password_params_ok?
      @user.password = params[:password]
      @user.forgot_password_token = ""
      @user.save
      flash[:notice] = "Your password has been changed"
      redirect_to controller: "sessions", action: "new"
    end
  end

  private

  def forgot_password_params_ok?
    if @user.forgot_password_token.blank?
      flash[:notice] = "Please enter your email address below"
      redirect_to action: "forgot_password"
      return false
    elsif params[:t].nil? || (@user.forgot_password_token != params[:t])
      flash[:notice] = "The link you entered was invalid. This can happen if you have re-requested " +
        "a forgot password email or you have already reset and changed your password."
      redirect_to action: "forgot_password"
      return false
    end
    true
  end

  def find_user
    @user = User.find(params[:id])
  end

  def admin_or_manager_or_same_user_required
    if !admin_or_manager? && (!logged_in? || (@current_user != @user))
      redirect_to controller: "sessions", action: "new"
      nil
    end
  end

  def can_users_create_accounts
    unless @w.can_users_create_accounts? || admin_or_manager?
      flash[:notice] = "New user accounts cannot be created."
      redirect_to root_path
    end
  end

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end
end
