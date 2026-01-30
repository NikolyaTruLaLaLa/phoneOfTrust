class Chat < ApplicationRecord
  AVAILABLE_STATUSES = %w[waiting active ended].freeze

  has_many :messages, dependent: :destroy

  validates :visitors_token, uniqueness: true, presence: true
  validates :status, presence: true, inclusion: { in: AVAILABLE_STATUSES }
  validates :visitors_init_token, presence: true, uniqueness: {
                                                                conditions: -> { where.not(status: "ended") }
                                                              }
  validate :protect_closed_status_change, on: :update

  def protect_closed_status_change
    if status_was == "ended" && status_changed?
      errors.add(:status, "закрытые записи нельзя изменять")
    end
  end
end
