class PagesController < ApplicationController
  before_filter :require_website

  def index
    @pages = Page.find(:all, :conditions => { :website_id => @website })
  end

  def show
    @page = Page.find_by_slug_and_website_id(params[:slug], @website)
    render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found" if @page.nil?
  end
  
  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    @page.website_id = @website.id

    if @page.save
      flash[:notice] = "Successfully added new page."
      redirect_to :action => "new"
    else
      render :action => "new"
    end
  end
end