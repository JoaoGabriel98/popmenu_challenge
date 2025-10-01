class MenuItemization < ApplicationRecord
  belongs_to :menu
  belongs_to :menu_item

  validates :menu_id, uniqueness: { scope: :menu_item_id }
  validates :price_cents,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }
end
