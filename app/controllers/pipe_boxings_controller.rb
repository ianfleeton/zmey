class PipeBoxingsController < ApplicationController
  def add_to_basket
    product_map = {
      'l_shape_1220' => 'L1220',
      'l_shape_2440' => 'L2440',
      'u_shape_1220' => 'U1220',
      'u_shape_2440' => 'U2440',
      'stop_end' => 'STOPEND',
      'external_corner' => 'EC',
      'internal_corner' => 'IC',
      'l_shape_joint_cover' => 'LJC',
      'u_shape_joint_cover' => 'UJC',
    }

    height = params[:height].to_i
    depth = params[:depth].to_i
    sku = "#{product_map[params[:product]]}-#{height}X#{depth}"

    product = Product.find_by(sku: sku, website_id: website.id)
    if product
      @basket.add(product, [], 1)
    end

    redirect_to basket_path
  end
end
