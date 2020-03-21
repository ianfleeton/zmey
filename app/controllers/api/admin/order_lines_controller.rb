class Api::Admin::OrderLinesController < Api::Admin::AdminController
  def create
    @order_line = OrderLine.new(order_line_params)

    if params[:order_line][:order_id].blank? || !Order.exists?(id: params[:order_line][:order_id])
      @order_line.errors.add(:base, "Order does not exist.")
    end

    if params[:order_line][:product_id].present?
      if @order_line.product.nil?
        @order_line.errors.add(:base, "Product is invalid")
      else
        @order_line.product_name = @order_line.product.name unless params[:order_line][:product_name]
        @order_line.product_price = @order_line.calculate_product_price unless params[:order_line][:product_price]
        @order_line.product_rrp = @order_line.product.rrp unless params[:order_line][:product_rrp]
        @order_line.product_sku = @order_line.product.sku
        @order_line.product_weight = @order_line.product.weight unless params[:order_line][:product_weight]
        @order_line.tax_amount = @order_line.calculate_tax_amount unless params[:order_line][:tax_amount]
      end
    end

    if @order_line.errors.any? || !@order_line.save
      render json: @order_line.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    if (@order_line = OrderLine.find_by(id: params[:id]))
      @order_line.destroy
      head 204
    else
      head 404
    end
  end

  private

  def order_line_params
    params.require(:order_line).permit(
      :order_id,
      :product_id,
      :product_name,
      :product_price,
      :product_rrp,
      :product_sku,
      :product_weight,
      :quantity,
      :tax_amount
    )
  end
end
