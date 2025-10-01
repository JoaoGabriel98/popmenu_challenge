class CreateMenuItemizations < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_itemizations do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end

    add_index :menu_itemizations, [ :menu_id, :menu_item_id ], unique: true
  end
end
