class Api::Admin::PagesController < Api::Admin::AdminController
  def index
    @pages = website.pages
    render nothing: true, status: 404 if @pages.empty?
  end

  def create
    @page = Page.new(page_params)
    @page.website = website
    @page.save
  end

  private

    def page_params
      params.require(:page).permit(:description, :name, :slug, :title)
    end
end
