class SessionsController < ApplicationController
  skip_before_action :protect_private_website

  def new
  end

  def create
    @current_user = User.authenticate(params[:email], params[:password])
    if @current_user
      session[:user] = @current_user.id
      if admin_or_manager?
        redirect_to orders_path
      else
        redirect_to @current_user
      end
    else
      flash[:notice] = "No user was found with this email/password"
      redirect_to action: 'new'
    end
  end

  def destroy
    reset_session
    
    flash[:notice] = "Logged out successfully"
    redirect_to action: 'new'
  end
end
