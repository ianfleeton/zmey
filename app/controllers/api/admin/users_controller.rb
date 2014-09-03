class Api::Admin::UsersController < Api::Admin::AdminController
  def index
    @users = website.users
  end

  def show
    @user = User.find_by(id: params[:id], website_id: website.id)
    render nothing: true, status: 404 unless @user
  end
end
