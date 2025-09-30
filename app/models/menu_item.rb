class MenuItem < ApplicationRecord
  belongs_to :menu

  validates :name, presence: true, uniqueness: { scope: :menu_id }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :available, inclusion: { in: [true, false] }
end
