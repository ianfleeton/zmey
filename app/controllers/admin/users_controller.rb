module Admin
  class UsersController < Admin::AdminController
    before_action :set_user, except: [:index, :new, :create]

    def index
      @users = User.order(:name)
        .paginate(page: params[:page], per_page: 100)
    end

    def show
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        flash[:notice] = I18n.t("controllers.admin.users.create.flash.created")
        redirect_to admin_users_path
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @user.update(user_params)
        flash[:notice] = I18n.t("controllers.admin.users.update.flash.updated")
        redirect_to [:admin, @user]
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: I18n.t("controller.admin.users.destroy.flash.destroyed")
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:customer_reference, :email, :name, :password, :password_confirmation)
    end
  end
end
