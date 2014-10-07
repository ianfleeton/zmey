class Admin::LiquidTemplatesController < Admin::AdminController
  before_action :find_liquid_template, only: [:edit, :update, :destroy]

  def index
    @liquid_templates = website.liquid_templates
  end

  def new
    @liquid_template = LiquidTemplate.new
  end

  def edit
  end

  def create
    @liquid_template = LiquidTemplate.new(liquid_template_params)
    @liquid_template.website_id = website.id

    if @liquid_template.save
      flash[:notice] = "Successfully added new Liquid template."
      redirect_to edit_admin_liquid_template_path(@liquid_template)
    else
      render :new
    end
  end

  def update
    if @liquid_template.update_attributes(liquid_template_params)
      flash[:notice] = "Liquid template successfully updated."
      redirect_to edit_admin_liquid_template_path(@liquid_template)
    else
      render :edit
    end
  end

  def destroy
    @liquid_template.destroy
    flash[:notice] = "Liquid template deleted."
    redirect_to admin_liquid_templates_path
  end

  protected

  def find_liquid_template
    @liquid_template = LiquidTemplate.find_by(id: params[:id], website_id: website.id)
    not_found unless @liquid_template
  end

    def liquid_template_params
      params.require(:liquid_template).permit(:markup, :name, :title)
    end
end
