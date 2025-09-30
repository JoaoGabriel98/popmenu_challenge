require 'rails_helper'

RSpec.describe Menu, type: :model do
  it { should have_many(:menu_items).dependent(:destroy) }
  it { should validate_presence_of(:name) }
end
