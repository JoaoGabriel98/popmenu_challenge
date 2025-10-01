require 'rails_helper'

RSpec.describe Menu, type: :model do
  it { should belong_to(:restaurant) }
  it { should have_many(:menu_itemizations).dependent(:destroy) }
  it { should have_many(:menu_items).through(:menu_itemizations) }
  it { should validate_presence_of(:name) }

  subject { build(:menu) }
  it { should validate_uniqueness_of(:name).scoped_to(:restaurant_id) }
end
