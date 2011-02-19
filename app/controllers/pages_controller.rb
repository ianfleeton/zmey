class PagesController < ApplicationController
  before_filter :admin_or_manager_required, :except => [:show, :sitemap, :terms]
  before_filter :find_page, :only => [:edit, :update, :destroy, :move_up, :move_down]

  def index
    @title = 'Pages'
    @pages = Page.find(:all, :conditions => { :website_id => @w, :parent_id => nil }, :order => :position)
  end

  def show
    @page = Page.find_by_slug_and_website_id(params[:slug], @w)
    if @page
      @title = @page.title
      @description = @page.description
      @keywords = @page.keywords
      if request.path == '/'
        @blog = @w.blog
      end
      if admin_or_manager?
        # set up objects for admin use
        @product_placement = ProductPlacement.new
      end
    else
      not_found
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

  # intra-list moving code from
  # http://blog.airbladesoftware.com/2008/3/19/moving-between-lists-with-acts_as_list
  def update
    new_position = params[:page].delete(:position).to_i
    old_parent_id = @page.parent_id
    if @page.update_attributes(params[:page])
      @page.move_to_position new_position if old_parent_id != @page.parent_id
      flash[:notice] = 'Page saved.'
      redirect_to page_path(@page)
    else
      @page.position = new_position
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
      redirect_to new_page_path
    else
      render :action => "new"
    end
  end

  def destroy
    @page.destroy
    flash[:notice] = "Page deleted."
    redirect_to :action => "index"
  end

  def terms
    @terms = @w.terms_and_conditions
  end

  def sitemap
    @pages = Array.new
    @pages.concat @w.pages.reject {|p| p.parent.nil?}
    @pages.concat @w.products
    @other_urls = ['/enquiries/new', '/users/forgot_password', '/users/new',
      '/sessions/new', '/basket', '/pages/terms'].collect{|x| 'http://' + @w.domain + x}

    respond_to do |format|
      format.xml { render :layout => false }
    end
  end

  protected
  
  def find_page
    @page = Page.find_by_id_and_website_id(params[:id], @w.id)
    unless @page
      not_found
    end
  end
  
  def moved
    flash[:notice] = 'Moved'
    redirect_to :action => 'index'
  end
end