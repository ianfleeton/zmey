class ProductsController < ApplicationController
  include ShowPage

  def show
    @product = Product.find_by(id: params[:id], website_id: website.id)

    if @product
      @title = @product.page_title.blank? ? @product.name + ' at ' + website.name : @product.page_title
      @description = @product.meta_description
      
      not_found unless @product.active? || admin?
    else
      show_page("products/#{params[:id]}")
    end
  end

  def google_data_feed
    @products = website.google_products
  end
end
