# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Menu.destroy_all

lunch = Menu.create!(name: "Lunch", description: "Lunch specials")
dinner = Menu.create!(name: "Dinner", description: "Evening menu")

lunch.menu_items.create!([
  { name: "Margherita", description: "Tomato, mozzarella, basil", price_cents: 2500, available: true },
  { name: "Pepperoni",  description: "Pepperoni & cheese",       price_cents: 2900, available: true }
])

dinner.menu_items.create!([
  { name: "Lasagna", description: "Layers of pasta & cheese", price_cents: 3200, available: true }
])

puts "Seeds ok!"
