FactoryBot.define do
  factory :menu_item do
    association :restaurant
    name { Faker::Food.dish }
    description { Faker::Food.description }
    price_cents { rand(500..5000) }
    available { [true, false].sample }
  end
end
