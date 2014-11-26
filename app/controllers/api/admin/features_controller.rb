class Api::Admin::FeaturesController < Api::Admin::AdminController
  def create
    @feature = Feature.new(feature_params)
    @feature.ui_type = Feature::TEXT_FIELD
    unless @feature.save
      render json: @feature.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

    def feature_params
      params.require(:feature).permit(:name, :product_id)
    end
end
