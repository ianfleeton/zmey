class Api::Admin::PagesController < Api::Admin::AdminController
  def index
    @pages = website.pages
    render nothing: true, status: 404 if @pages.empty?
  end

  def create
    @page = Page.new(page_params)
    @page.website = website
    unless @page.save
      render json: @page.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

    def page_params
      params.require(:page).permit(:description, :name, :slug, :title)
    end
end
