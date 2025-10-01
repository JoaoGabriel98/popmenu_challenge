require 'rails_helper'

RSpec.describe "MenuItems Level 2", type: :request do
  describe "under restaurant" do
    it "creates items for a restaurant and lists with filters" do
      r = create(:restaurant)
      post "/restaurants/#{r.id}/menu_items",
           params: { menu_item: { name: "Margherita", price_cents: 2500, available: true } }
      expect(response).to have_http_status(:created)

      get "/restaurants/#{r.id}/menu_items", params: { available: true, q: "mar" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.size).to eq(1)
      expect(body.first["name"]).to eq("Margherita")
    end

    it "prevents duplicate names within same restaurant" do
      r = create(:restaurant)
      post "/restaurants/#{r.id}/menu_items", params: { menu_item: { name: "Pepperoni", price_cents: 1000 } }
      post "/restaurants/#{r.id}/menu_items", params: { menu_item: { name: "Pepperoni", price_cents: 1200 } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
