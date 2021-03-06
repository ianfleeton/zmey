class Api::Admin::PagesController < Api::Admin::AdminController
  before_action :set_page, only: [:show]

  def index
    @pages = Page.all
  end

  def show
  end

  def create
    @page = Page.new(page_params)

    if params[:image_id].present? && !Image.exists?(id: params[:image_id], website_id: website.id)
      @page.errors.add(:base, "Image does not exist.")
    end

    if params[:thumbnail_image_id].present? && !Image.exists?(id: params[:thumbnail_image_id], website_id: website.id)
      @page.errors.add(:base, "Thubmnail image does not exist.")
    end

    if @page.errors.any? || !@page.save
      render json: @page.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    Page.destroy_all
    head 204
  end

  private

  def set_page
    @page = Page.find_by(id: params[:id])
    head 404 unless @page
  end

  def page_params
    params.require(:page).permit(:content, :description, :extra, :image_id,
      :name, :no_follow,
      :no_index, :parent_id, :slug,
      :thumbnail_image_id,
      :title, :visible)
  end
end
