class AddTermsAndConditionsToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :terms_and_conditions, :text, :default => '', :null => false
  end

  def self.down
    remove_column :websites, :terms_and_conditions
  end
end
