class Api::Admin::PagesController < Api::Admin::AdminController
  def index
    @pages = website.pages
    render nothing: true, status: 404 if @pages.empty?
  end
end
