# frozen_string_literal: true

module Admin
  # Admin interface for managing closure dates.
  class ClosureDatesController < AdminController
    before_action :set_closure_date, only: [:edit, :update, :destroy]

    def index
      @closure_dates = ClosureDate.order("closed_on")
    end

    def new
      @closure_date = ClosureDate.new
    end

    def create
      @closure_date = ClosureDate.new(closure_date_params)

      if @closure_date.save
        redirect_to admin_closure_dates_path, notice: "Saved."
      else
        render :new
      end
    end

    def update
      if @closure_date.update(closure_date_params)
        flash[:notice] = "Saved."
        redirect_to admin_closure_dates_path
      else
        render :edit
      end
    end

    def destroy
      @closure_date.destroy
      redirect_to admin_closure_dates_path, notice: "Deleted."
    end

    def simulate
      if params[:start_time]
        lead_time = params[:lead_time].to_i
        spec = Shipping::DispatchDeliverySpec.new(
          start: Time.parse(params[:start_time]),
          lead: lead_time,
          delivery: params[:delivery_time].to_i,
          cutoff: params[:cutoff_hour].to_i,
          num: 10,
          items: [BasketItem.new(product: Product.new(lead_time: lead_time))]
        )
        @dates = Shipping::DispatchDeliveryDate.list(spec)
      end
    end

    protected

    def set_closure_date
      @closure_date = ClosureDate.find_by(id: params[:id])
    end

    def closure_date_params
      params.require(:closure_date).permit(:closed_on, :delivery_possible)
    end
  end
end
