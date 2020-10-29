# frozen_string_literal: true

module Admin
  # Admin interface for managing couriers.
  class CouriersController < AdminController
    before_action :find_courier, only: [:edit, :update, :destroy]

    def index
      @couriers = Courier.order("name")
    end

    def new
      @courier = Courier.new
    end

    def create
      @courier = Courier.new(courier_params)

      if @courier.save
        redirect_to admin_couriers_path, notice: "Saved."
      else
        render :new
      end
    end

    def update
      if @courier.update(courier_params)
        flash[:notice] = "Saved."
        redirect_to admin_couriers_path
      else
        render :edit
      end
    end

    def destroy
      @courier.destroy
      redirect_to admin_couriers_path, notice: "Deleted."
    end

    protected

    def find_courier
      @courier = Courier.find_by(id: params[:id])
    end

    def courier_params
      params.require(:courier).permit(
        :account_number, :consignment_prefix, :name, :tracking_url
      )
    end
  end
end
