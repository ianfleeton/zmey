class Api::Admin::ProductsController < Api::Admin::AdminController
  before_action :set_nominal_code, only: [:create]

  def index
    @products = website.products
  end

  def show
    @product = Product.find_by(id: params[:id], website_id: website.id)
    render nothing: true, status: 404 unless @product
  end

  def create
    @product = Product.new(product_params)
    @product.website = website
    @product.nominal_code = @nominal_code

    unless @product.save
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    website.products.destroy_all
    render nothing: :true, status: 204
  end

  private

    def product_params
      params.require(:product).permit(:brand, :description, :image_id,
      :meta_description, :name,
      :page_title, :price, :sku, :tax_type, :weight)
    end

    def set_nominal_code
      if params['product']['nominal_code']
        @nominal_code = NominalCode.find_by(code: params['product']['nominal_code'], website_id: website.id)
        params['product'].delete('nominal_code')
      else
        @nominal_code = nil
      end
    end
end
