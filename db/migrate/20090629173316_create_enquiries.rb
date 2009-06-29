class CreateEnquiries < ActiveRecord::Migration
  def self.up
    create_table :enquiries do |t|
      t.string :name, :default => '', :null => false
      t.string :organisation, :default => '', :null => false
      t.text :address, :default => '', :null => false
      t.string :country, :default => '', :null => false
      t.string :postcode, :default => '', :null => false
      t.string :telephone, :default => '', :null => false
      t.string :email, :default => '', :null => false
      t.string :fax, :default => '', :null => false
      t.text :enquiry, :default => '', :null => false
      t.string :call_back, :default => '', :null => false
      t.string :hear_about, :default => '', :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :enquiries
  end
end
