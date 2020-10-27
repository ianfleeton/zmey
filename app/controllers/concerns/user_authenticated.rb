module UserAuthenticated
  extend ActiveSupport::Concern

  def user_authenticated
    if @current_user.email_verified_at?
      session[:unverified_user_id] = nil
      change_user
      redirect_to_safe_path(account_path)
    else
      # Re-enable the unverified user prompt.
      session[:unverified_user_id] = @current_user.id
      redirect_to account_verify_email_new_path
    end
  end

  def change_user
    old_session = session.to_hash
    reset_session
    session.update(old_session)
    session[:email] = @current_user.email
    session[:name] = @current_user.name
    session[:user_id] = @current_user.id
  end

  def redirect_to_safe_path(fallback)
    redirect_to safe_redirect_path(fallback)
  end

  private

  def safe_redirect_path(fallback)
    return fallback if params[:unsafe_redirect_url].blank?
    URI.parse(params[:unsafe_redirect_url]).path
  rescue URI::InvalidURIError
    fallback
  end
end
