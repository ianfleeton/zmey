class RemoveWebsiteIdFromEnquiries < ActiveRecord::Migration[6.1]
  def change
    remove_column :enquiries, :website_id
  end
end
