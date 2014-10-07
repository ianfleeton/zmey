class Api::Admin::LiquidTemplatesController < Api::Admin::AdminController
  def delete_all
    website.liquid_templates.destroy_all
    render nothing: :true, status: 204
  end
end
