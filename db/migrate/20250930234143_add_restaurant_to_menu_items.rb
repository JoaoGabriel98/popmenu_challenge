class AddRestaurantToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :menu_items, :restaurant, null: true, foreign_key: true
    add_index :menu_items, [ :restaurant_id, :name ], unique: true
  end
end
