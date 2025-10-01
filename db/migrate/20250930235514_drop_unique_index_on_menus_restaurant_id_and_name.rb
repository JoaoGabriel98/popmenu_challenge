class DropUniqueIndexOnMenusRestaurantIdAndName < ActiveRecord::Migration[8.0]
  def change
    if index_exists?(:menus, [ :restaurant_id, :name ])
      remove_index :menus, column: [ :restaurant_id, :name ]
    end
  end
end
