require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  it { should have_many(:menus).dependent(:destroy) }
  it { should have_many(:menu_items).dependent(:destroy) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:slug) }

  subject { create(:restaurant) }

  it { should validate_uniqueness_of(:slug) }
end
