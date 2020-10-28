class Admin::ShipmentsController < Admin::AdminController
  def new
    @shipment = Shipment.new(order_id: params[:order_id])
  end

  def create
    @shipment = Shipment.new(shipment_params)
    if @shipment.save
      redirect_to edit_admin_order_path(@shipment.order)
    else
      render "new"
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
