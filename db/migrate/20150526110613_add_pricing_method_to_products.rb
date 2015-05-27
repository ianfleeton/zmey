class AddPricingMethodToProducts < ActiveRecord::Migration
  def change
    add_column :products, :pricing_method, :string, null: false, default: 'basic'
  end
end
