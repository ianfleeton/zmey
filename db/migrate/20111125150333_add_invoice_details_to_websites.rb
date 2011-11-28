class AddInvoiceDetailsToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :invoice_details, :text
  end
end
