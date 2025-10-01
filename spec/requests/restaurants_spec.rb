require 'rails_helper'

RSpec.describe "Restaurants", type: :request do
  describe "GET /restaurants" do
    it "lists restaurants" do
      create_list(:restaurant, 2)
      get "/restaurants"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe "POST /restaurants" do
    it "creates a restaurant" do
      post "/restaurants", params: { restaurant: { name: "Roma", slug: "roma" } }
      expect(response).to have_http_status(:created)
    end

    it "validates slug uniqueness" do
      create(:restaurant, slug: "roma")
      post "/restaurants", params: { restaurant: { name: "Roma 2", slug: "roma" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /restaurants/:id" do
    it "shows restaurant with its menus" do
      r = create(:restaurant)
      create(:menu, restaurant: r, name: "Lunch")
      get "/restaurants/#{r.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["menus"].size).to eq(1)
    end
  end
end
