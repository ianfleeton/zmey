class AddTermsAndConditionsToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :terms_and_conditions, :text
  end

  def self.down
    remove_column :websites, :terms_and_conditions
  end
end
