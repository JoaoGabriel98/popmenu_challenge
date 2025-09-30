require 'rails_helper'

RSpec.describe "Menus", type: :request do
  describe "GET /menus" do
    it "returns menus" do
      create_list(:menu, 2)
      get "/menus"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end
  end

  describe "POST /menus" do
    it "creates a menu" do
      post "/menus", params: { menu: { name: "Lunch", description: "..." } }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq("Lunch")
    end

    it "validates presence of name" do
      post "/menus", params: { menu: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /menus/:id" do
    it "shows a menu with items" do
      menu = create(:menu)
      create(:menu_item, menu:)
      get "/menus/#{menu.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["menu_items"].size).to eq(1)
    end
  end
end
