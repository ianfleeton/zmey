class LiquidTemplatesController < ApplicationController
  before_filter :admin_or_manager_required
  before_filter :find_liquid_template, :only => [:edit, :update, :destroy]

  def index
    @liquid_templates = @w.liquid_templates
  end

  def new
    @liquid_template = LiquidTemplate.new
  end

  def edit
  end

  def create
    @liquid_template = LiquidTemplate.new(params[:liquid_template])
    @liquid_template.website_id = @w.id

    if @liquid_template.save
      flash[:notice] = "Successfully added new Liquid template."
      redirect_to edit_liquid_template_path(@liquid_template)
    else
      render :action => "new"
    end
  end

  def update
    if @liquid_template.update_attributes(params[:liquid_template])
      flash[:notice] = "Liquid template successfully updated."
      redirect_to edit_liquid_template_path(@liquid_template)
    else
      render :action => "edit"
    end
  end

  def destroy
    @liquid_template.destroy
    flash[:notice] = "Liquid template deleted."
    redirect_to liquid_templates_path
  end

  protected

  def find_liquid_template
    @liquid_template = LiquidTemplate.find_by_id_and_website_id(params[:id], @w.id)
    unless @liquid_template
      render :file => "#{::Rails.root.to_s}/public/404.html", :status => "404 Not Found"
    end
  end
end
