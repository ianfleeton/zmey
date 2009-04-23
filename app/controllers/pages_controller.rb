class PagesController < ApplicationController
  before_filter :require_website

  def show
    @page = Page.find_by_slug_and_website_id(params[:slug], @website)
    render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found" if @page.nil?
  end
  
  def new
    @page = Page.new
  end

end