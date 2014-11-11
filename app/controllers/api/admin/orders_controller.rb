class Api::Admin::OrdersController < Api::Admin::AdminController
  include Enums::Conversions

  before_action :set_order, only: [:show, :update]

  def index
    page      = params[:page] || 1
    per_page  = params[:page_size] || default_page_size
    @orders   = index_query.paginate(page: page, per_page: per_page)
  end

  def show
  end

  def create
    if params[:order][:status]
      params[:order][:status] = PaymentStatus(params[:order][:status]).to_i
    end

    @order = Order.new(order_params)
    @order.website = website

    unless @order.save
      render json: @order.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    @order.update_attributes(order_params)

    if @order.save
      render nothing: true, status: 204
    else
      render json: @order.errors.full_messages, status: :unprocessable_entity
    end
  end

  # Returns the default number of orders to include in a collection request.
  def default_page_size
    50
  end

  def delete_all
    website.orders.destroy_all
    render nothing: :true, status: 204
  end

  private

    def set_order
      @order = Order.find_by(id: params[:id], website_id: website.id)
      render nothing: true, status: 404 unless @order
    end

    # Returns a query for the index action using filters in +params+.
    def index_query
      order_number = params[:order_number]
      processed    = api_boolean(params[:processed])

      conditions = {}
      not_conditions = {}
      conditions[:order_number] = order_number if order_number
      if params[:status]
        conditions[:status] = PaymentStatus(params[:status])
      end

      if processed == false
        conditions[:processed_at] = nil
      elsif processed == true
        not_conditions[:processed_at] = nil
      end

      website.orders.where(conditions).where.not(not_conditions)
    end

    def order_params
      params.require(:order).permit(
      :billing_address_line_1,
      :billing_address_line_2,
      :billing_country_id,
      :billing_full_name,
      :billing_postcode,
      :billing_town_city,
      :customer_note,
      :delivery_address_line_1,
      :delivery_address_line_2,
      :delivery_country_id,
      :delivery_full_name,
      :delivery_postcode,
      :delivery_town_city,
      :email_address,
      :status,
      :processed_at
      )
    end
end
