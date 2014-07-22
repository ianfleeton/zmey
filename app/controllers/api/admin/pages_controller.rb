class Api::Admin::PagesController < Api::Admin::AdminController
  def index
    @pages = website.pages
  end

  def create
    @page = Page.new(page_params)
    @page.website = website
    unless @page.save
      render json: @page.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    website.pages.destroy_all
    render nothing: :true, status: 204
  end

  private

    def page_params
      params.require(:page).permit(:description, :image_id, :name, :no_follow,
      :no_index, :parent_id, :slug, :title)
    end
end
