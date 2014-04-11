class Api::Admin::ProductsController < Api::Admin::AdminController
  def delete_all
    website.products.destroy_all
    render nothing: :true, status: 204
  end
end
