FactoryBot.define do
  factory :menu do
    name { "Menu #{Faker::Food.ethnic_category}" }
    description { Faker::Food.description }
  end
end
