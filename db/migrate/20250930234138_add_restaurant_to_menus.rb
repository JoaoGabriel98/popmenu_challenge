class AddRestaurantToMenus < ActiveRecord::Migration[8.0]
  def change
    add_reference :menus, :restaurant, null: true, foreign_key: true
    add_index :menus, [ :restaurant_id, :name ], unique: true
  end
end
