class Api::Admin::UsersController < Api::Admin::AdminController
  def index
    @users = index_query
  end

  def show
    @user = User.find_by(id: params[:id], website_id: website.id)
    render nothing: true, status: 404 unless @user
  end

  private

    def index_query
      email = params[:email]

      conditions = {}
      conditions[:email] = email if email

      User.where(conditions)
    end
end
