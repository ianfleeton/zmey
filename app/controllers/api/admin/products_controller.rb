class Api::Admin::ProductsController < Api::Admin::AdminController
  def index
    page      = params[:page] || 1
    per_page  = params[:page_size] || default_page_size

    @now = Time.zone.now
    @products = Product.all

    if params[:updated_since]
      @products = @products.where ['updated_at >= ?', Time.parse(params[:updated_since])]
    end

    @products   = @products.paginate(page: page, per_page: per_page)
  end

  def show
    @product = Product.find_by(id: params[:id])
    render nothing: true, status: 404 unless @product
  end

  def create
    @product = Product.new(product_params)

    unless @product.save
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    Product.destroy_all
    render nothing: :true, status: 204
  end

  private

    def product_params
      params.require(:product).permit(
      :allow_fractional_quantity,
      :brand, :description,
      :extra,
      :google_description,
      :image_id,
      :meta_description, :name,
      :page_title, :price,
      :pricing_method,
      :purchase_nominal_code,
      :rrp,
      :sales_nominal_code,
      :sku,
      :submit_to_google,
      :tax_type, :weight)
    end
end
