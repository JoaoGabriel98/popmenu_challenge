# spec/models/menu_item_spec.rb
require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  subject { build(:menu_item) }

  it { should belong_to(:menu) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:menu_id) }
  it { should validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }
end
