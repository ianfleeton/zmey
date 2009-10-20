class PagesController < ApplicationController
  before_filter :admin_required, :except => [:show]
  before_filter :find_page, :only => [:edit, :update, :destroy, :move_up, :move_down]

  def index
    @title = 'Pages'
    @pages = Page.find(:all, :conditions => { :website_id => @w, :parent_id => nil }, :order => :position)
  end

  def show
    @page = Page.find_by_slug_and_website_id(params[:slug], @w)
    if @page
      @title = @page.title
      if admin?
        # set up objects for admin use
        @product_placement = ProductPlacement.new
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found"
    end
  end
  
  def edit
  end

  def move_up
    @page.move_higher
    moved
  end
  
  def move_down
    @page.move_lower
    moved
  end

  def update
    if @page.update_attributes(params[:page])
      flash[:notice] = 'Page saved.'
      redirect_to page_path(@page)
    else
      render :action => 'edit'
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

  def destroy
    @page.destroy
    flash[:notice] = "Page deleted."
    redirect_to :action => "index"
  end

  protected
  
  def find_page
    @page = Page.find(params[:id])
  end
  
  def moved
    flash[:notice] = 'Moved'
    redirect_to :action => 'index'
  end
end