class Admin::ExtraAttributesController < Admin::AdminController
  def new
    @extra_attribute = ExtraAttribute.new
  end

  def create
    @extra_attribute = ExtraAttribute.new(extra_attribute_params)
    if @extra_attribute.save
      redirect_to admin_extra_attributes_path
    else
      render 'new'
    end
  end

  private

    def extra_attribute_params
      params.require(:extra_attribute).permit(
      :attribute_name,
      :class_name,
      )
    end
end
