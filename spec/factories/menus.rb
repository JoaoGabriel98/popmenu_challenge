FactoryBot.define do
  factory :menu do
    association :restaurant
    name { "Menu #{Faker::Food.ethnic_category}" }
    description { Faker::Food.description }
  end
end
