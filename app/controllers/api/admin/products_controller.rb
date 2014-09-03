class Api::Admin::ProductsController < Api::Admin::AdminController
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
end
