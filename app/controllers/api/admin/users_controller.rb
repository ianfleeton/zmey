class Api::Admin::UsersController < Api::Admin::AdminController
  before_action :set_user, only: [:show, :update]

  def index
    @users = index_query
  end

  def show
  end

  def update
    @user.update_attributes(user_params)

    if @user.save
      head 204
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

    def set_user
      @user = User.find_by(id: params[:id])
      head 404 unless @user
    end

    def index_query
      email = params[:email]

      conditions = {}
      conditions[:email] = email if email

      User.where(conditions)
    end

    def user_params
      params.require(:user).permit(:customer_reference)
    end
end
