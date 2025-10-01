class Level2BackfillAndRestructure < ActiveRecord::Migration[8.0]
  disable_ddl_transaction! # we're going to control the transations

  def up
    ActiveRecord::Base.transaction do
      default_insert = execute(<<-SQL.squish)
        INSERT INTO restaurants (name, slug, created_at, updated_at)
        VALUES ('Default Restaurant', 'default-restaurant', NOW(), NOW())
        ON CONFLICT (slug) DO NOTHING
        RETURNING id;
      SQL
      default_restaurant_id =
        if default_insert.any?
          default_insert.first['id']
        else
          execute("SELECT id FROM restaurants WHERE slug='default-restaurant' LIMIT 1").first['id']
        end

      execute <<-SQL.squish
        UPDATE menus
           SET restaurant_id = #{default_restaurant_id}
         WHERE restaurant_id IS NULL;
      SQL

      execute <<-SQL.squish
        UPDATE menu_items mi
           SET restaurant_id = COALESCE(
               (SELECT m.restaurant_id FROM menus m WHERE m.id = mi.menu_id),
               #{default_restaurant_id}
           )
         WHERE restaurant_id IS NULL;
      SQL

      execute <<-SQL.squish
        INSERT INTO menu_itemizations (menu_id, menu_item_id, position, created_at, updated_at)
        SELECT mi.menu_id, mi.id, NULL, NOW(), NOW()
          FROM menu_items mi
         WHERE mi.menu_id IS NOT NULL
           AND NOT EXISTS (
                 SELECT 1 FROM menu_itemizations mzi
                  WHERE mzi.menu_id = mi.menu_id
                    AND mzi.menu_item_id = mi.id
               );
      SQL

      execute <<-SQL.squish
        WITH ranked AS (
          SELECT id, restaurant_id, name,
                 ROW_NUMBER() OVER (PARTITION BY restaurant_id, name ORDER BY id) AS rn
            FROM menus
        )
        UPDATE menus
           SET name = menus.name || ' (' || ranked.rn || ')'
          FROM ranked
         WHERE menus.id = ranked.id
           AND ranked.rn > 1;
      SQL

      execute <<-SQL.squish
        WITH ranked AS (
          SELECT id, restaurant_id, name,
                 ROW_NUMBER() OVER (PARTITION BY restaurant_id, name ORDER BY id) AS rn
            FROM menu_items
        )
        UPDATE menu_items
           SET name = menu_items.name || ' (' || ranked.rn || ')'
          FROM ranked
         WHERE menu_items.id = ranked.id
           AND ranked.rn > 1;
      SQL

      remove_reference :menu_items, :menu, foreign_key: true

      change_column_null :menus, :restaurant_id, false
      change_column_null :menu_items, :restaurant_id, false

      add_index :menus, [ :restaurant_id, :name ], unique: true
    end
  end

  def down
    add_reference :menu_items, :menu, null: true, foreign_key: true

    execute <<-SQL.squish
      UPDATE menu_items mi
         SET menu_id = sub.menu_id
        FROM (
          SELECT menu_item_id, MIN(menu_id) AS menu_id
            FROM menu_itemizations
        GROUP BY menu_item_id
        ) sub
      WHERE mi.id = sub.menu_item_id
        AND mi.menu_id IS NULL;
    SQL

    change_column_null :menu_items, :menu_id, false
    change_column_null :menus, :restaurant_id, true
    change_column_null :menu_items, :restaurant_id, true

    if index_exists?(:menus, [ :restaurant_id, :name ])
      remove_index :menus, column: [ :restaurant_id, :name ]
    end
  end
end
