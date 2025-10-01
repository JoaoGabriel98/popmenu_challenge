class AddPriceCentsToMenuItemizations < ActiveRecord::Migration[8.0]
  def change
    add_column :menu_itemizations, :price_cents, :integer, null: true
    add_index  :menu_itemizations, :price_cents
  end
end
