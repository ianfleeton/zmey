class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  def show
    @title = @product.page_title.blank? ? @product.name + ' at ' + website.name : @product.page_title
    @description = @product.meta_description
  end
  
  def google_data_feed
    @products = website.google_products
  end

  private
  
    def set_product
      @product = Product.find_by(id: params[:id], website_id: website.id)
      not_found unless @product
    end
end
