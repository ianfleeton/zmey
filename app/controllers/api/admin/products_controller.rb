class Api::Admin::ProductsController < Api::Admin::AdminController
  def create
    @product = Product.new(product_params)
    @product.website = website
    @product.save
  end

  def delete_all
    website.products.destroy_all
    render nothing: :true, status: 204
  end

  private

    def product_params
      params.require(:product).permit(:description, :meta_description, :name,
      :price, :sku)
    end
end
