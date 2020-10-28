class Api::Admin::ShipmentsController < Api::Admin::AdminController
  def create
    @shipment = Shipment.new(shipment_params)
    if params[:shipment][:order_id].blank? || !Order.exists?(id: params[:shipment][:order_id])
      @shipment.errors.add(:base, "Order does not exist.")
    end
    if @shipment.errors.any? || !@shipment.save
      render json: @shipment.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def shipment_params
    params.require(:shipment).permit(
      :consignment_number,
      :courier_id,
      :number_of_parcels,
      :order_id,
      :partial,
      :picked_by,
      :shipped_at,
      :total_weight,
      :tracking_url
    )
  end
end
