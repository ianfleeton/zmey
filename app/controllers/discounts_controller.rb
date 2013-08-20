class DiscountsController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required
  before_filter :find_discount, only: [:edit, :update, :destroy]

  def index
    @discounts = @w.discounts
  end

  def new
    @discount = Discount.new
  end

  def edit
  end

  def create
    @discount = Discount.new(discount_params)
    @discount.website_id = @w.id

    if @discount.save
      redirect_to discounts_path, notice: 'Successfully added new discount.'
    else
      render action: 'new'
    end
  end

  def update
    if @discount.update_attributes(discount_params)
      flash[:notice] = "Discount successfully updated."
      redirect_to discounts_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @discount.destroy
    redirect_to discounts_path, notice: 'Discount deleted.'
  end

  protected

  def find_discount
    @discount = Discount.find_by_id_and_website_id(params[:id], @w.id)
    not_found unless @discount
  end

  def discount_params
    params.require(:discount).permit(:coupon, :free_products_group_id, :name, :reward_type)
  end
end
