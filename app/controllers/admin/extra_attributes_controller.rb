class Admin::ExtraAttributesController < Admin::AdminController
  before_action :set_extra_attribute, only: [:destroy, :edit]

  def index
    @extra_attributes = ExtraAttribute.all
  end

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

  def edit
  end

  def destroy
    @extra_attribute.destroy
    redirect_to admin_extra_attributes_path
  end

  private

    def extra_attribute_params
      params.require(:extra_attribute).permit(
      :attribute_name,
      :class_name,
      )
    end

    def set_extra_attribute
      @extra_attribute = ExtraAttribute.find(params[:id])
    end
end
