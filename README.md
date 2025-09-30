# Popmenu Challenge — Level 1 (Rails + PostgreSQL)

This repository contains a minimal, production-ready **Level 1** implementation for the Popmenu coding challenge.
Stack: **Ruby on Rails + PostgreSQL + RSpec**.

## What Level 1 Includes

* **Models:** `Menu` (has many) → `MenuItem`
* **Validations:** presence/format + **unique** `MenuItem.name` **scoped to menu**
* **DB Constraints:** `NOT NULL`, defaults, indexes (including unique composite index)
* **Controllers/Routes:** CRUD for menus and menu items; list & filter endpoints
* **Seeds:** sample data for quick inspection
* **Tests:** RSpec model and request specs (with FactoryBot, Shoulda)

## Next Steps (for Level 2+)

* Introduce `Restaurant` and evolve relationships (e.g., one restaurant with multiple menus; item reuse rules).
* Add pagination, sorting, and more filters.
* Add serializers (e.g., Blueprinter/AMS) for response stability.
* Add import endpoints/services and CLI tasks (Level 3).

---

## License

For interview/evaluation purposes. Use freely for this challenge.
