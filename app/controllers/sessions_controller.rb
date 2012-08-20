class SessionsController < ApplicationController
  skip_before_filter :protect_private_website

  def new
  end

  def create
    @current_user = User.authenticate(params[:email], params[:password])
    if @current_user
      session[:user] = @current_user.id
      redirect_to @current_user
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
