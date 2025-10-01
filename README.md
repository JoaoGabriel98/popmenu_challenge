# Popmenu Challenge — Rails + PostgreSQL (Levels 1 → 3)

A production-ready implementation of the Popmenu coding challenge, delivered iteratively across **Level 1, Level 2, and Level 3**.
Stack: **Ruby on Rails** · **PostgreSQL** · **RSpec**.

## Warning

I advice to have a look on the closed PR's to make this challenge. This is because I wanted to show a sense of progress. On the PR, I talk about the changes a little bit.

## Quickstart

### Requirements

* Ruby **3.2+** (works on 3.3.x)
* Rails **7.1+**
* PostgreSQL **13+**

### Setup

```bash
# 1) Install gems
bundle install

# 2) Configure database (adjust username/password as needed)
# config/database.yml expects:
#   PGUSER=popmenu
#   PGPASSWORD=popmenu
# or edit the file to match your local setup

# Optionally create a local DB role:
psql -U postgres -c "CREATE ROLE popmenu WITH LOGIN PASSWORD 'popmenu';"
psql -U postgres -c "ALTER ROLE popmenu CREATEDB;"

# 3) Create and migrate databases
bin/rails db:create
bin/rails db:migrate

# 4) (Optional) Seed sample data
bin/rails db:seed

# 5) Run the server
bin/rails server
# API at http://localhost:3000
```

---

## Domain by Level

### Level 1

**Goal:** Minimal menu system.

* **Models:** `Menu` (has many) → `MenuItem`
* **Validations:** presence + uniqueness for `MenuItem.name` **scoped to menu**
* **DB constraints:** `NOT NULL`, defaults, indexes, and a **composite unique index** to prevent duplicates within a menu
* **Controllers/Routes:** CRUD for menus and items; list & filter endpoints
* **Seeds & Tests:** seeds for quick inspection; RSpec model & request specs

---

### Level 2

**Goal:** Multiple menus per restaurant; reusable items.

* **New model:** `Restaurant`
* **Menu** now `belongs_to :restaurant`
* **MenuItem** now `belongs_to :restaurant` (no longer belongs to a menu)
* **Menu ↔ MenuItem** becomes **many-to-many** via `MenuItemization`
* **Uniqueness rule:** `MenuItem.name` is **unique per restaurant**
* **Endpoints:**

  * Create/list **menus within a restaurant**
  * Create/list **items within a restaurant**
  * **Link / unlink** existing items to menus
* **Backfill migration:** moves Level 1 data safely, de-duplicates names if needed, and re-enables unique indexes
* **Tests:** model specs & request specs (including link/unlink)

**ER Diagram (Level 2)**

```
Restaurant (1) ── (N) Menu
Restaurant (1) ── (N) MenuItem
Menu (N) ── (N) MenuItem   via MenuItemization
```

> Migration tip used here: temporarily drop unique index on `menus(restaurant_id, name)` for backfill; re-add it after cleaning duplicates.

---

### Level 3

**Goal:** JSON import endpoint + conversion tool; per-menu prices.

* **HTTP endpoint** that accepts **JSON** and/or **file upload**:

  * `POST /imports/restaurant_json` with `multipart/form-data` (`file`) **or**
  * `application/json` body `{ "data": { ... } }`
* **Importer service** (`Importers::RestaurantDataImporter`) that:

  * Parses restaurants/menus/items from JSON
  * Accepts items under `menu_items` **or** `dishes`
  * Deduplicates repeated item names in the **same menu** within the payload
  * Upserts **Restaurant**, **Menu**, **MenuItem**
  * **Links items to menus** via `MenuItemization`
  * Returns a **log per item** and an overall `success/fail`
* **Per-menu price support:** add `price_cents` to **`menu_itemizations`** so the same item (e.g., “Burger”) can cost differently in **lunch** vs **dinner**
* **CLI task:** `rake import:restaurants[path/to/restaurant_data.json]`
* **Robust logging & exception handling**
* **Tests:** service spec + endpoint (request) spec

---

## Examples (cURL)

```bash
# Create a restaurant
curl -X POST http://localhost:3000/restaurants \
 -H "Content-Type: application/json" \
 -d '{"restaurant":{"name":"Pizzeria Roma","slug":"pizzeria-roma"}}'

# Create menus within a restaurant
curl -X POST http://localhost:3000/restaurants/1/menus \
 -H "Content-Type: application/json" \
 -d '{"menu":{"name":"Lunch","description":"Daytime specials"}}'

curl -X POST http://localhost:3000/restaurants/1/menus \
 -H "Content-Type: application/json" \
 -d '{"menu":{"name":"Dinner","description":"Evening menu"}}'

# Create items within a restaurant
curl -X POST http://localhost:3000/restaurants/1/menu_items \
 -H "Content-Type: application/json" \
 -d '{"menu_item":{"name":"Burger","price_cents":1200,"available":true}}'

curl -X POST http://localhost:3000/restaurants/1/menu_items \
 -H "Content-Type: application/json" \
 -d '{"menu_item":{"name":"Large Salad","price_cents":800,"available":true}}'

# Link items to menus (re-use across multiple menus)
curl -X POST http://localhost:3000/restaurants/1/menus/1/menu_items/1/link
curl -X POST http://localhost:3000/restaurants/1/menus/2/menu_items/1/link
curl -X POST http://localhost:3000/restaurants/1/menus/2/menu_items/2/link

# Show a menu (includes per-menu price)
curl http://localhost:3000/menus/2

# Unlink an item
curl -X DELETE http://localhost:3000/restaurants/1/menus/2/menu_items/2/unlink

# List items with filters
curl "http://localhost:3000/restaurants/1/menu_items?available=true&q=burger"
```

**Responses** are JSON. Validation failures return **422 Unprocessable Content** with error messages.

---

## Importer (HTTP & CLI)

### HTTP Endpoint (Level 3)

`POST /imports/restaurant_json`

* **multipart/form-data** with a `file` (JSON), **or**
* **application/json** body:

  ```json
  { "data": { "restaurants": [ ... ] } }
  ```

**Example payload** (shortened from the challenge/mocked sample; supports `menu_items` or `dishes` arrays under a menu):

```json
{
  "restaurants": [
    {
      "name": "Poppo's Cafe",
      "menus": [
        {
          "name": "lunch",
          "menu_items": [
            { "name": "Burger", "price": 9.00 },
            { "name": "Small Salad", "price": 5.00 }
          ]
        },
        {
          "name": "dinner",
          "menu_items": [
            { "name": "Burger", "price": 15.00 },
            { "name": "Large Salad", "price": 8.00 }
          ]
        }
      ]
    }
  ]
}
```

### CLI Task

```bash
# Pretty-prints the same JSON result (and exits non-zero on failure)
rake import:restaurants[path/to/restaurant_data.json]
```
## Testing

```bash
# Prepare test DB
bin/rails db:environment:set RAILS_ENV=test
bin/rails db:test:prepare

# Run the suite
bundle exec rspec
```

## Design Decisions & Assumptions

* **Prices as integers (`*_cents`)** to avoid floating-point rounding issues.
* **Per-menu price** lives on the **join** (`menu_itemizations.price_cents`).
  `menu_items.price_cents` serves as an optional default/legacy value.
* **Uniqueness scope** for `MenuItem.name` is **per restaurant**; different restaurants may have items with the same name.
  (Switch to global uniqueness by enforcing a unique index on `menu_items.name` alone.)
* **Idempotent imports**: upserts by `(restaurant.slug)`, `(restaurant_id, menu.name)`, and `(restaurant_id, item.name)`.
* **Backfill safety (Level 2)**: temporarily drop `menus(restaurant_id, name)` unique index during backfill; de-duplicate then re-add.
* **Logging & errors**: the importer returns a structured log list plus `success`/`errors_count`, and continues processing after per-item errors.

## Project Structure

```
app/
  controllers/
    imports_controller.rb
    menu_items_controller.rb
    menus_controller.rb
    restaurants_controller.rb
  models/
    menu.rb
    menu_item.rb
    menu_itemization.rb
    restaurant.rb
  services/
    importers/
      restaurant_data_importer.rb
config/
  routes.rb
db/
  migrate/
  seeds.rb
lib/
  tasks/
    import.rake
spec/
  fixtures/
    files/
      restaurant_data.json
  factories/
    menu_itemizations.rb
    menu_items.rb
    menus.rb
    restaurants.rb
  models/
    menu_item_spec.rb
    menu_itemization_spec.rb
    menu_spec.rb
    restaurant_spec.rb
  requests/
    imports_spec.rb
    menu_items_level2_spec.rb
    menus_level2_spec.rb
    restaurants_spec.rb
  services/
    importers/
      restaurant_data_importer_spec.rb
```
## License

For interview/evaluation purposes
