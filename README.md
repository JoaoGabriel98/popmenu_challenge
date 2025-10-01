# Popmenu Challenge — (Rails + PostgreSQL)

This repository contains a minimal, production-ready **Level 1** implementation for the Popmenu coding challenge.
Stack: **Ruby on Rails + PostgreSQL + RSpec**.

## What Level 1 Includes

* **Models:** `Menu` (has many) → `MenuItem`
* **Validations:** presence/format + **unique** `MenuItem.name` **scoped to menu**
* **DB Constraints:** `NOT NULL`, defaults, indexes (including unique composite index)
* **Controllers/Routes:** CRUD for menus and menu items; list & filter endpoints
* **Seeds:** sample data for quick inspection
* **Tests:** RSpec model and request specs (with FactoryBot, Shoulda)

## What Level 2 Includes

* **Models & Relationships:**
  * New **`Restaurant`** model
  * **`Menu`** now `belongs_to :restaurant`
  * **`MenuItem`** now `belongs_to :restaurant` *(no longer belongs to a menu)*
  * **`Menu` ↔ `MenuItem`** is **many-to-many** via **`MenuItemization`**

* **Uniqueness Rule:**
  * **`MenuItem.name`** is **unique per restaurant** *(scoped by `restaurant_id`)*
  * If you prefer **global** uniqueness, enforce a unique index on **`menu_items.name`** alone

* **Controllers/Routes (Endpoints):**
  * **Create/List Menus** within a restaurant
  * **Create/List Items** within a restaurant
  * **Link / Unlink** existing items to menus

* **Tests:**
  * RSpec coverage (**models + requests**) aligned with the new Level 2 domain


## Next Steps (for Level 2+)

* Introduce `Restaurant` and evolve relationships (e.g., one restaurant with multiple menus; item reuse rules).
* Add pagination, sorting, and more filters.
* Add serializers (e.g., Blueprinter/AMS) for response stability.
* Add import endpoints/services and CLI tasks (Level 3).

---

## License

For interview/evaluation purposes. Use freely for this challenge.
