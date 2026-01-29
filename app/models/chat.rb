class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy


  validates :visitors_token, uniqueness: true, presence: true
  validates :status, presence: true
  validates :visitors_init_token, uniqueness: true, presence: true
end
