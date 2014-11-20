class AddMandrillSubaccountToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :mandrill_subaccount, :string, default: '', null: false
  end
end
