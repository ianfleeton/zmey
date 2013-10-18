class Admin::UsersController < ApplicationController
  before_action :set_user, except: [:index, :new, :create]
  before_action :admin_required, only: [:destroy]
  before_action :admin_or_manager_required, except: [:destroy]

  layout 'admin'

  def index
    @users = website.users
  end
  
  def show
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    @user.admin = false
    @user.website = website
    
    if @user.save
      flash[:notice] = "New user account has been created."
      redirect_to users_path
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
      redirect_to [:admin, @user]
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, 'User account successfully destroyed.'
  end

  private
  
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :name, :password, :password_confirmation)
    end
end
