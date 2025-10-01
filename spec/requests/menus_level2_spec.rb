require 'rails_helper'

RSpec.describe "Menus Level 2", type: :request do
  describe "nested under restaurant" do
    it "creates and shows menu" do
      r = create(:restaurant)
      post "/restaurants/#{r.id}/menus", params: { menu: { name: "Dinner", description: "Evening" } }
      expect(response).to have_http_status(:created)
      menu_id = JSON.parse(response.body)["id"]

      get "/restaurants/#{r.id}/menus"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first["name"]).to eq("Dinner")

      get "/menus/#{menu_id}"
      expect(response).to have_http_status(:ok)
    end

    it "prevents duplicate menu names within same restaurant" do
      r = create(:restaurant)
      create(:menu, restaurant: r, name: "Lunch")
      post "/restaurants/#{r.id}/menus", params: { menu: { name: "Lunch" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "link/unlink items to menu" do
    it "links an existing restaurant item to a menu" do
      r = create(:restaurant)
      m = create(:menu, restaurant: r)
      item = create(:menu_item, restaurant: r)

      post "/restaurants/#{r.id}/menus/#{m.id}/menu_items/#{item.id}/link"
      expect(response).to have_http_status(:ok)

      get "/menus/#{m.id}"
      body = JSON.parse(response.body)
      expect(body["menu_items"].map { |i| i["id"] }).to include(item.id)
    end

    it "unlinks an item" do
      r = create(:restaurant)
      m = create(:menu, restaurant: r)
      item = create(:menu_item, restaurant: r)

      post "/restaurants/#{r.id}/menus/#{m.id}/menu_items/#{item.id}/link"
      delete "/restaurants/#{r.id}/menus/#{m.id}/menu_items/#{item.id}/unlink"
      expect(response).to have_http_status(:no_content)
    end
  end
end
