class AddCanonicalPageIdToPages < ActiveRecord::Migration[6.0]
  def change
    add_reference :pages, :canonical_page, null: true, foreign_key: {to_table: :pages}
  end
end
