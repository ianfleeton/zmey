module Account
  # Lets customers reset a forgotten password, or set one for an account that
  # was created automatically at checkout.
  #
  # Reset links use the token from has_secure_password, which expires and
  # stops working once the password has been changed.
  class ForgotPasswordController < ApplicationController
    include UserAuthenticated

    # Minimum time between reset emails to the same account.
    RESEND_INTERVAL = 5.minutes

    before_action :set_user_from_token, only: %i[new change]

    def index
    end

    # Responds the same way whether or not the email address has an account,
    # so the form can't be used to find out who is registered.
    def send_email
      user = User.find_by(email: params[:email].to_s)
      send_reset_email(user) if user && !recently_sent?(user)
      redirect_to action: "sent"
    end

    def sent
    end

    def new
    end

    def change
      @user.password = params[:password].to_s
      @user.email_verified_at ||= Time.current
      if @user.save
        UserNotifier.password_changed(website, @user).deliver_later
        @current_user = @user
        flash[:notice] = "Your password has been changed"
        user_authenticated
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def recently_sent?(user)
      user.forgot_password_sent_at.present? &&
        user.forgot_password_sent_at > RESEND_INTERVAL.ago
    end

    def send_reset_email(user)
      user.update_column(:forgot_password_sent_at, Time.current)
      UserNotifier.password_reset(website, user).deliver_later
    end

    def set_user_from_token
      @user = User.find_by_password_reset_token(params[:t].to_s)
      return if @user

      flash[:notice] = I18n.t("controllers.account.forgot_password.invalid_link")
      redirect_to action: "index"
    end
  end
end
