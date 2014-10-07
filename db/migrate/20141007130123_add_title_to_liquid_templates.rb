class AddTitleToLiquidTemplates < ActiveRecord::Migration
  def change
    add_column :liquid_templates, :title, :string, default: '', null: false
  end
end
