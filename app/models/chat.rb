class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :visitors_token, uniqueness: true
  validates :status, presence: true

end