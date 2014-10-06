class Admin::PagesController < Admin::AdminController
  before_action :set_page, only: [:edit, :update, :destroy, :move_up, :move_down]

  def index
    @title = 'Pages'
    @parent = params[:parent_id] ? Page.find_by(id: params[:parent_id], website_id: website.id) : nil
    @pages = Page.select(:id, :name, :parent_id, :position, :slug, :title).where(website_id: website, parent_id: @parent.try(:id)).order(:position)
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
    params[:page].delete(:position)
    if @page.update_attributes(page_params)
      flash[:notice] = 'Page saved.'
      redirect_to edit_admin_page_path(@page)
    else
      @page.position = new_position
      render :edit
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
      redirect_to admin_pages_path(parent_id: @page.parent_id)
    end

    def page_params
      params.require(:page).permit(:content, :description, :extra, :image_id, :name,
      :no_follow, :no_index, :parent_id, :slug, :thumbnail_image_id, :title)
    end
end
