class SessionsController < ApplicationController
  skip_before_action :protect_private_website
  before_action :admin_required, only: [:switch_user]

  def new
  end

  def create
    @current_user = User.authenticate(params[:email], params[:password])
    if @current_user
      set_user
    else
      flash[:notice] = "No user was found with this email/password"
      redirect_to action: 'new'
    end
  end

  def destroy
    if session[:admin]
      @current_user = User.find(session[:admin])
      set_user
    else
      reset_session
      flash[:notice] = "Logged out successfully"
      redirect_to action: 'new'
    end
  end

  def switch_user
    admin_id = @current_user.id
    @current_user = User.find(params[:user_id])
    set_user
    session[:admin] = admin_id
  end

  private

    def set_user
      reset_session
      session[:user] = @current_user.id
      if admin_or_manager?
        redirect_to admin_path
      else
        redirect_to @current_user
      end
    end
end

