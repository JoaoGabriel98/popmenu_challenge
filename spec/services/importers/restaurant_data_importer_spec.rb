require "rails_helper"

RSpec.describe Importers::RestaurantDataImporter do
  let(:payload) do
    JSON.parse(File.read(Rails.root.join("spec/fixtures/files/restaurant_data.json")))
  end

  # helper opcional para evitar hardcode do slug
  def slug_of(name)
    name.parameterize
  end

  it "imports restaurants, menus, items and links with per-menu prices" do
    result = described_class.new(payload: payload).call
    expect(result[:success]).to eq(true)
    expect(result[:errors_count]).to be >= 0
    expect(result[:logs]).to be_an(Array)

    expect(Restaurant.count).to eq(2)

    r1 = Restaurant.find_by(slug: slug_of("Poppo's Cafe"))
    r2 = Restaurant.find_by(slug: slug_of("Casa del Poppo"))
    expect(r1).to be_present
    expect(r2).to be_present

    lunch_r1  = r1.menus.find_by(name: "lunch")
    dinner_r1 = r1.menus.find_by(name: "dinner")
    expect(lunch_r1).to be_present
    expect(dinner_r1).to be_present

    burger_r1 = r1.menu_items.find_by(name: "Burger")
    expect(burger_r1).to be_present

    mi_lunch  = MenuItemization.find_by(menu: lunch_r1,  menu_item: burger_r1)
    mi_dinner = MenuItemization.find_by(menu: dinner_r1, menu_item: burger_r1)
    expect(mi_lunch.price_cents).to eq(900)
    expect(mi_dinner.price_cents).to eq(1500)

    lunch_r2 = r2.menus.find_by(name: "lunch")
    wings    = r2.menu_items.find_by(name: "Chicken Wings")
    expect(wings).to be_present

    links_wings = MenuItemization.where(menu: lunch_r2, menu_item: wings).count
    expect(links_wings).to eq(1)
  end
end
