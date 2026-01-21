class Message < ApplicationRecord
  belongs_to :chat

  scope :sorted, -> { order(:id)}
  validates :content, presence: true
  validates :sender, presence: true
end
