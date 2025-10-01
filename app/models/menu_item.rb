class MenuItem < ApplicationRecord
  belongs_to :restaurant

  has_many :menu_itemizations, dependent: :destroy
  has_many :menus, through: :menu_itemizations

  validates :name, presence: true, uniqueness: { scope: :restaurant_id }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :available, inclusion: { in: [ true, false ] }
end
