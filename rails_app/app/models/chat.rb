class Chat < ApplicationRecord
  belongs_to :app
  has_many :messages, dependent: :destroy
  validates :number, presence: true
  validates :number, uniqueness: { scope: :app_id }
end
