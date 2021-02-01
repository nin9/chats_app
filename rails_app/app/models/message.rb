class Message < ApplicationRecord
  searchkick text_start: [:body]

  belongs_to :chat
  validates :number, :body, presence: true
  validates :number, uniqueness: { scope: :chat_id }
end
