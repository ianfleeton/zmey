class OrderLinesController < ApplicationController
  before_filter :admin_required

  def update
    @order_line = OrderLine.find(params[:id])
    if @order_line.update_attributes(params[:order_line])
      flash[:notice] = 'Updated.'
    else
      flash[:notice] = 'Could not update.'
    end
    redirect_to @order_line.order
  end
end
