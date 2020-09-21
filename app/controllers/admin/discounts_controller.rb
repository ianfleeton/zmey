class Admin::DiscountsController < Admin::AdminController
  before_action :find_discount, only: [:edit, :update, :destroy]

  def index
    @discounts = Discount.order(:name)
  end

  def new
    @discount = Discount.new(valid_to: Time.zone.now + 5.years)
  end

  def edit
  end

  def create
    @discount = Discount.new(discount_params)

    if @discount.save
      redirect_to admin_discounts_path, notice: "Successfully added new discount."
    else
      render :new
    end
  end

  def update
    if @discount.update(discount_params)
      flash[:notice] = "Discount successfully updated."
      redirect_to admin_discounts_path
    else
      render :edit
    end
  end

  def destroy
    @discount.destroy
    redirect_to admin_discounts_path, notice: "Discount deleted."
  end

  protected

  def find_discount
    @discount = Discount.find_by(id: params[:id])
    not_found unless @discount
  end

  def discount_params
    params.require(:discount).permit(:coupon, :exclude_reduced_products, :product_group_id, :name, :reward_amount, :reward_type, :threshold, :valid_from, :valid_to)
  end
end
