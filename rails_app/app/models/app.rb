class App < ApplicationRecord
  has_secure_token
  validates :name, presence: true
  validates :token, uniqueness: true
  has_many :chats, dependent: :destroy
end
