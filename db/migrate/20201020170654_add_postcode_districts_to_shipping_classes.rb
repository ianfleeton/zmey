class AddPostcodeDistrictsToShippingClasses < ActiveRecord::Migration[6.0]
  def change
    add_column :shipping_classes, :postcode_districts, :text
  end
end
