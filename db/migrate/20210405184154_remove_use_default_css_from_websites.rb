class RemoveUseDefaultCssFromWebsites < ActiveRecord::Migration[6.1]
  def change
    remove_column :websites, :use_default_css
  end
end
