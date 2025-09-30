class CreateMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items do |t|
      t.references :menu, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false, default: 0
      t.boolean :available, null: false, default: true

      t.timestamps
    end

    add_index :menu_items, [:menu_id, :name], unique: true
    add_index :menu_items, :available
  end
end
