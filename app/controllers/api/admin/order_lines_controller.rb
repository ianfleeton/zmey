class Api::Admin::OrderLinesController < Api::Admin::AdminController
  def create
    @order_line = OrderLine.new(order_line_params)

    if params[:order_line][:order_id].blank? || !Order.exists?(id: params[:order_line][:order_id], website_id: website.id)
      @order_line.errors.add(:base, 'Order does not exist.')
    end

    if params[:order_line][:product_id].present?
      if @order_line.product.nil?
        @order_line.errors.add(:base, 'Product is invalid')
      else
        @order_line.product_price = @order_line.calculate_product_price
        @order_line.product_sku = @order_line.product.sku
        @order_line.tax_amount = @order_line.calculate_tax_amount
      end
    end

    if @order_line.errors.any? || !@order_line.save
      render json: @order_line.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

    def order_line_params
      params.require(:order_line).permit(
        :order_id,
        :product_id,
        :product_price,
        :product_sku,
        :quantity,
        :tax_amount
      )
    end
end
