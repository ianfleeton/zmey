class Admin::OrderCommentsController < Admin::AdminController
  def new
    order = Order.find(params[:order_id])
    @order_comment = OrderComment.new(order: order)
  end

  def create
    @order_comment = OrderComment.new(order_comment_params)
    if @order_comment.save
      redirect_to edit_admin_order_path(@order_comment.order)
    else
      render 'new'
    end
  end

  private

    def order_comment_params
      params.require(:order_comment).permit(:comment, :order_id)
    end
end
