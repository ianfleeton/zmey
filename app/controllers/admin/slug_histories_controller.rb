module Admin
  class SlugHistoriesController < AdminController
    def index
      @slug_histories = SlugHistory.includes(:page).all.sort { |a, b|
        a.page.name <=> b.page.name
      }
    end

    def create
      SlugHistory.create!(slug_history_params)
      redirect_to admin_slug_histories_path, notice: "Added."
    end

    def destroy
      SlugHistory.find(params[:id]).destroy
      redirect_to admin_slug_histories_path, notice: "Deleted."
    end

    def slug_history_params
      params.require(:slug_history).permit(:slug, :page_id)
    end
  end
end
