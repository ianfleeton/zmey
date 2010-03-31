class CreatePreferredDeliveryDateSettings < ActiveRecord::Migration
  def self.up
    create_table :preferred_delivery_date_settings do |t|
      t.integer :website_id, :default => 0, :null => false
      t.string :prompt, :default => 'Preferred delivery date', :null => false
      t.string :date_format, :default => '%a %d %b'
      t.integer :number_of_dates_to_show, :default => 5, :null => false
      t.string :rfc2822_week_commencing_day 
      t.integer :number_of_initial_days_to_skip, :default => 1, :null => false
      t.string :skip_after_time_of_day
      t.boolean :skip_bank_holidays, :default => true, :null => false
      t.boolean :skip_saturdays, :default => true, :null => false
      t.boolean :skip_sundays, :default => true, :null => false

      t.timestamps
    end
    add_index :preferred_delivery_date_settings, :website_id
  end

  def self.down
    drop_table :preferred_delivery_date_settings
  end
end
