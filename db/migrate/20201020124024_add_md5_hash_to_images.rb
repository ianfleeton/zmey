class AddMd5HashToImages < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :md5_hash, :string, limit: 32
    add_index :images, :md5_hash
  end
end
