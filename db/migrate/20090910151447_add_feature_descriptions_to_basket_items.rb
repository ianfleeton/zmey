class AddFeatureDescriptionsToBasketItems < ActiveRecord::Migration
  def self.up
    add_column :basket_items, :feature_descriptions, :text
  end

  def self.down
    remove_column :basket_items, :feature_descriptions
  end
end
