require 'rails_helper'

RSpec.describe MenuItemization, type: :model do
  subject { build(:menu_itemization) }

  it { should belong_to(:menu) }
  it { should belong_to(:menu_item) }
  it { should validate_uniqueness_of(:menu_id).scoped_to(:menu_item_id) }
end
