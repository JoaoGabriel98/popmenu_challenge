require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  subject { build(:menu_item) }

  it { should belong_to(:restaurant) }
  it { should have_many(:menu_itemizations).dependent(:destroy) }
  it { should have_many(:menus).through(:menu_itemizations) }
  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }
  it { should validate_uniqueness_of(:name).scoped_to(:restaurant_id) }
end
