FactoryBot.define do
  factory :menu_itemization do
    association :menu
    association :menu_item
    position { nil }
  end
end
