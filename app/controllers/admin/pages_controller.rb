module Admin
  class PagesController < AdminController
    before_action :set_page, only: [:edit, :update, :destroy, :move_up, :move_down]

    def index
      @title = "Pages"
      @parent = params[:parent_id] ? Page.find_by(id: params[:parent_id]) : nil
      @pages = Page.select(:id, :name, :parent_id, :position, :slug, :title).where(parent_id: @parent.try(:id)).order(:position)
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
      @page.update_extra(params)
      if @page.update(page_params)
        flash[:notice] = "Page saved."
        redirect_to edit_admin_page_path(@page)
      else
        render :edit
      end
    end

    def new
      @page = Page.new(parent_id: params[:parent_id])
    end

    def create
      @page = Page.new(page_params)

      if @page.save
        flash[:notice] = "Successfully added new page."
        redirect_to new_admin_page_path
      else
        render :new
      end
    end

    def destroy
      @page.destroy
      redirect_to action: "index", notice: "Page deleted."
    end

    def new_shortcut
      set_parent
    end

    def create_shortcut
      random = SecureRandom.hex
      set_parent
      canonical = Page.find(params[:target_id])
      name = params[:name].present? ? params[:name] : canonical.name
      page = Page.new(
        canonical_page: canonical,
        parent: @parent,
        name: name,
        title: random,
        slug: random,
        description: random
      )
      if page.save
        redirect_to(
          admin_pages_path(parent_id: @parent), notice: "Shortcut created."
        )
      else
        flash[:alert] =
          I18n.t("controllers.admin.pages.create_shortcut.duplicate_name")
        redirect_to new_shortcut_admin_pages_path(parent_id: params[:parent_id])
      end
    end

    def search
      @pages = Page.admin_search(params[:query])
      render json: @pages
    end

    def search_products
      @products = Product.admin_search(params[:query])
      render layout: false
    end

    protected

    def set_page
      @page = Page.find_by(id: params[:id])
      not_found unless @page
    end

    def set_parent
      @parent = params[:parent_id] ? Page.find_by(id: params[:parent_id]) : nil
    end

    def moved
      flash[:notice] = "Moved"
      redirect_to admin_pages_path(parent_id: @page.parent_id)
    end

    def page_params
      params.require(:page).permit(:content, :description, :image_id, :name,
        :no_follow, :no_index, :parent_id, :slug, :thumbnail_image_id, :title,
        :visible)
    end
  end
end
