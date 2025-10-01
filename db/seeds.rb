# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

MenuItemization.delete_all
Menu.delete_all
MenuItem.delete_all
Restaurant.delete_all

r1 = Restaurant.create!(name: "Pizzeria Roma", slug: "pizzeria-roma")
r2 = Restaurant.create!(name: "Tokyo Bites",  slug: "tokyo-bites")

lunch_r1  = r1.menus.create!(name: "Lunch",  description: "Daytime specials")
dinner_r1 = r1.menus.create!(name: "Dinner", description: "Evening menu")

margherita = r1.menu_items.create!(name: "Margherita", description: "Tomato, mozzarella, basil", price_cents: 2500, available: true)
pepperoni  = r1.menu_items.create!(name: "Pepperoni",  description: "Pepperoni & cheese",       price_cents: 2900, available: true)
lasagna    = r1.menu_items.create!(name: "Lasagna",     description: "Layers of pasta & cheese", price_cents: 3200, available: true)

[lunch_r1, dinner_r1].each do |m|
  [margherita, pepperoni].each { |it| MenuItemization.find_or_create_by!(menu: m, menu_item: it) }
end
MenuItemization.find_or_create_by!(menu: dinner_r1, menu_item: lasagna)

lunch_r2 = r2.menus.create!(name: "Lunch", description: "Bentos & bowls")
r2.menu_items.create!(name: "Teriyaki Chicken", description: "Sweet soy glaze", price_cents: 3500, available: true)
r2.menu_items.create!(name: "Margherita", description: "Yes, same name — different restaurant", price_cents: 2700, available: true)

puts "Level 2 seeds loaded!"
