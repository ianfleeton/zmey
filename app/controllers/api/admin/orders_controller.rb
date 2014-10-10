class Api::Admin::OrdersController < Api::Admin::AdminController
  def index
    page      = params[:page] || 1
    per_page  = params[:page_size] || default_page_size
    @orders   = index_query.paginate(page: page, per_page: per_page)
  end

  def show
    @order = Order.find_by(id: params[:id], website_id: website.id)
    render nothing: true, status: 404 unless @order
  end

  # Returns the default number of orders to include in a collection request.
  def default_page_size
    50
  end

  private

    # Returns a query for the index action using filters in +params+.
    def index_query
      status     = Order.status_from_api(params[:status])
      processed  = api_boolean(params[:processed])

      conditions = {}
      not_conditions = {}
      conditions[:status] = status if status

      if processed == false
        conditions[:processed_at] = nil
      elsif processed == true
        not_conditions[:processed_at] = nil
      end

      website.orders.where(conditions).where.not(not_conditions)
    end
end
