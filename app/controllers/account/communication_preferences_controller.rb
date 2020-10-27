module Account
  # Communication preferences controller for customers that aren't necessarily
  # signed in.
  class CommunicationPreferencesController < ApplicationController
    # Provides options to opt-in or opt-out.
    def index
    end

    # Provides option only to opt-out.
    def unsubscribe
    end

    def update
      user = User.find_by(email: params[:email])
      if user
        user.update_explicit_opt_in(params[:wanted] == "Yes Please")
        user.save
        redirect_to action: :updated
      else
        redirect_to(
          {action: :index},
          notice: I18n.t(
            "controllers.account.communication_preferences.update.unrecognised"
          )
        )
      end
    end
  end
end
