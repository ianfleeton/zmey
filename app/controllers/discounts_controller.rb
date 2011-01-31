class DiscountsController < ApplicationController
  before_filter :admin_or_manager_required
  before_filter :find_discount, :only => [:edit, :update, :destroy]

  def index
    @discounts = @w.discounts
  end

  def new
    @discount = Discount.new
  end

  def edit
  end

  def create
    @discount = Discount.new(params[:discount])
    @discount.website_id = @w.id

    if @discount.save
      flash[:notice] = "Successfully added new discount."
      redirect_to discounts_path
    else
      render :action => "new"
    end
  end

  def update
    if @discount.update_attributes(params[:discount])
      flash[:notice] = "Discount successfully updated."
      redirect_to discounts_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @discount.destroy
    flash[:notice] = "Discount deleted."
    redirect_to discounts_path
  end

  protected

  def find_discount
    @discount = Discount.find_by_id_and_website_id(params[:id], @w.id)
    unless @discount
      render :file => "#{::Rails.root.to_s}/public/404.html", :status => "404 Not Found"
    end
  end
end
