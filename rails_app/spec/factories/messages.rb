FactoryBot.define do
  sequence :unique_msg_number do |n|
    n
  end

  factory :message do
    chat
    body { Faker::Lorem.sentence(word_count: 3) }
    number { generate :unique_msg_number }
  end
end
