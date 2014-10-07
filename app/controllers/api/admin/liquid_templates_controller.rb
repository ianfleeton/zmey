class Api::Admin::LiquidTemplatesController < Api::Admin::AdminController
  def create
    begin
      @liquid_template = LiquidTemplate.new(liquid_template_params)
    rescue ActionController::ParameterMissing
      @liquid_template = LiquidTemplate.new
    end
    @liquid_template.website = website

    if !@liquid_template.save
      render json: @liquid_template.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    website.liquid_templates.destroy_all
    render nothing: :true, status: 204
  end

  private

    def liquid_template_params
      params.require(:liquid_template).permit(:markup, :name, :title)
    end
end
