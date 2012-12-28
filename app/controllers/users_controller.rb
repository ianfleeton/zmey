class UsersController < ApplicationController
  before_filter :find_user, except: [:index, :new, :create, :forgot_password, :forgot_password_send]
  before_filter :admin_or_manager_or_same_user_required, only: [:show, :edit]
  before_filter :admin_required, only: [:destroy]
  before_filter :admin_or_manager_required, only: [:index]
  before_filter :can_users_create_accounts, only: [:new, :create]

  def index
    @users = @w.users
    render layout: 'admin'
  end
  
  def show
    @title = 'Your Account'
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.admin = false
    @user.website_id = @w.id
    
    if @user.save
      if admin_or_manager?
        flash[:notice] = "New user account has been created."
        redirect_to users_path
      else
        @current_user  = @user
        session[:user] = @user.id
        flash[:notice] = "Your account has been created."
        redirect_to @user
      end
    else
      render action: 'new'
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

    if @user.update_attributes(params[:user])
      flash[:notice] = "User successfully updated."
      redirect_to @user
    else
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, 'User account successfully destroyed.'
  end

  def forgot_password
  end
  
  def forgot_password_send
    @user = User.find_by_email(params[:email])
    if @user.nil?
      flash[:notice] = "There is no user registered with that email address"
      redirect_to action: 'forgot_password'
    else
      @user.forgot_password_token = User.generate_forgot_password_token
      @user.save
      UserNotifier.token(@w, @user).deliver
    end
  end

  def forgot_password_new
    forgot_password_params_ok?
  end
  
  def forgot_password_change
    if forgot_password_params_ok?
      @user.password = params[:password]
      @user.forgot_password_token = ''
      @user.save
      flash[:notice] = 'Your password has been changed'
      redirect_to controller: 'sessions', action: 'new'
    end
  end
  
  private
  
  def forgot_password_params_ok?
    if @user.forgot_password_token.blank?
      flash[:notice] = "Please enter your email address below"
      redirect_to action: 'forgot_password'
      return false
    elsif params[:t].nil? or @user.forgot_password_token != params[:t]
      flash[:notice] = "The link you entered was invalid. This can happen if you have re-requested " +
        "a forgot password email or you have already reset and changed your password."
      redirect_to action: 'forgot_password'
      return false
    end
    true
  end
  
  def find_user
    @user = User.find(params[:id])
  end

  def admin_or_manager_or_same_user_required
    if !admin_or_manager? and (!logged_in? or @current_user != @user)
      redirect_to controller: 'sessions', action: 'new'
      return
    end
  end

  def can_users_create_accounts
    unless @w.can_users_create_accounts? or admin_or_manager?
      flash[:notice] = 'New user accounts cannot be created.'
      redirect_to root_path
    end
  end
end
