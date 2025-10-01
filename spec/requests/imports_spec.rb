require "rails_helper"

RSpec.describe "Imports", type: :request do
  let(:payload) do
    JSON.parse(File.read(Rails.root.join("spec/fixtures/files/restaurant_data.json")))
  end

  it "imports via JSON payload" do
    post "/imports/restaurant_json", params: { data: payload }
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["success"]).to eq(true)
    expect(body["logs"]).to be_an(Array)
  end

  it "imports via file upload" do
    file = fixture_file_upload("restaurant_data.json", "application/json")
    post "/imports/restaurant_json", params: { file: file }
    expect(response).to have_http_status(:ok)
  end
end
