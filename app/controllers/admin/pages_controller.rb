class Admin::PagesController < ApplicationController
  layout 'admin'
  before_action :admin_or_manager_required
  before_action :set_page, only: [:edit, :update, :destroy, :move_up, :move_down]

  def index
    @title = 'Pages'
    @pages = Page.where(website_id: website, parent_id: nil).order(:position)
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
    if @page.update_attributes(page_params)
      @page.move_to_position new_position if old_parent_id != @page.parent_id
      flash[:notice] = 'Page saved.'
      redirect_to edit_admin_page_path(@page)
    else
      @page.position = new_position
      render action: 'edit'
    end
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)
    @page.website = website

    if @page.save
      flash[:notice] = "Successfully added new page."
      redirect_to new_admin_page_path
    else
      render :new
    end
  end

  def destroy
    @page.destroy
    redirect_to action: 'index', notice: 'Page deleted.'
  end

  protected
  
    def set_page
      @page = Page.find_by(id: params[:id], website_id: website.id)
      not_found unless @page
    end
  
    def moved
      flash[:notice] = 'Moved'
      redirect_to action: 'index'
    end

    def page_params
      params.require(:page).permit(:content, :description, :image_id, :name, :parent_id, :slug, :title)
    end
end
