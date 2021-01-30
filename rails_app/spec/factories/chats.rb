FactoryBot.define do
  sequence :unique_chat_number do |n|
    n
  end

  factory :chat do
    app
    number { generate :unique_chat_number }
  end
end
