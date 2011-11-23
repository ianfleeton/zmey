class CreateLiquidTemplates < ActiveRecord::Migration
  def change
    create_table :liquid_templates do |t|
      t.integer :website_id, :null => false
      t.string :name, :null => false
      t.text :markup

      t.timestamps
    end

    add_index :liquid_templates, :website_id
    add_index :liquid_templates, :name
  end
end
