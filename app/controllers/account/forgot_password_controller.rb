module Account
  class ForgotPasswordController < ApplicationController
    include UserAuthenticated
    before_action :set_user, only: %i[new change]

    def index
    end

    def send_email
      @user = User.find_by(email: params[:email])
      if @user.nil?
        flash[:notice] = "There is no user registered with that email address"
        redirect_to action: "index"
      else
        @user.forgot_password_token = User.generate_token
        @user.forgot_password_sent_at = Time.current
        @user.save
        UserNotifier.token(@w, @user).deliver_now
        redirect_to action: "sent"
      end
    end

    def sent
    end

    def new
      params_ok?
    end

    def change
      return unless params_ok?
      @user.password = params[:password]
      @user.forgot_password_token = ""
      @user.email_verified_at ||= Time.current
      @user.save
      UserNotifier.password_changed(website, @user).deliver_later

      @current_user = @user
      user_authenticated
      flash[:notice] = "Your password has been changed"
    end

    private

    def params_ok?
      if @user.forgot_password_token.blank?
        flash[:notice] = "Please enter your email address below"
        redirect_to action: "index"
      elsif params[:t].nil? || @user.forgot_password_token != params[:t]
        flash[:notice] = "The link you entered was invalid. This can happen " \
          "if you have re-requested a forgot password email or you have " \
          "already reset and changed your password."
        redirect_to action: "index"
      elsif token_expired?
        flash[:notice] = I18n.t("controllers.account.forgot_password.expired")
        redirect_to action: "index"
      end
      !performed?
    end

    def token_expired?
      @user.forgot_password_sent_at.present? &&
        @user.forgot_password_sent_at <= Time.current - 1.hour
    end

    def set_user
      @user = User.find(params[:id])
    end
  end
end
