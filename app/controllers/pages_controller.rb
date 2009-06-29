class PagesController < ApplicationController
  before_filter :require_website

  def index
    @pages = Page.find(:all, :conditions => { :website_id => @w })
  end

  def show
    @page = Page.find_by_slug_and_website_id(params[:slug], @w)
    if @page
      @title = @page.title
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found"
    end
  end
  
  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    @page.website_id = @w.id

    if @page.save
      flash[:notice] = "Successfully added new page."
      redirect_to :action => "new"
    else
      render :action => "new"
    end
  end
end