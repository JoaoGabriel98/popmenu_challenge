require 'rails_helper'

RSpec.describe "MenuItems", type: :request do
  describe "GET /menu_items" do
    it "lists items with filters" do
      create(:menu_item, name: "Margherita", available: true)
      create(:menu_item, name: "Diavola", available: false)

      get "/menu_items", params: { available: true, q: "mar" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first["name"]).to eq("Margherita")
    end
  end

  describe "POST /menus/:menu_id/menu_items" do
    it "creates an item for a menu" do
      menu = create(:menu)
      post "/menus/#{menu.id}/menu_items", params: {
        menu_item: { name: "Pepperoni", price_cents: 2500, available: true }
      }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["menu_id"]).to eq(menu.id)
      expect(json["name"]).to eq("Pepperoni")
    end

    it "rejects duplicate item name within the same menu" do
      menu = create(:menu)
      create(:menu_item, menu:, name: "Pepperoni")

      post "/menus/#{menu.id}/menu_items", params: {
        menu_item: { name: "Pepperoni", price_cents: 1000 }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /menu_items/:id" do
    it "updates an item" do
      item = create(:menu_item, name: "Old")
      patch "/menu_items/#{item.id}", params: { menu_item: { name: "New" } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("New")
    end
  end

  describe "DELETE /menu_items/:id" do
    it "deletes an item" do
      item = create(:menu_item)
      delete "/menu_items/#{item.id}"
      expect(response).to have_http_status(:no_content)
      expect(MenuItem.exists?(item.id)).to be_falsey
    end
  end
end
