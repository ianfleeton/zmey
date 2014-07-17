class Api::Admin::UsersController < Api::Admin::AdminController
  def index
    @users = website.users
  end
end
