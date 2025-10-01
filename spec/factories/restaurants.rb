FactoryBot.define do
  factory :restaurant do
    name { "Resto #{SecureRandom.hex(4)}" }
    slug { |r| r.name.parameterize }
  end
end
