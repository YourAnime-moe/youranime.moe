class Users::Like < ApplicationRecord
  belongs_to :show, inverse_of: :reactions
  belongs_to :user, inverse_of: :reactions

  scope :disabled, -> { where(is_disabled: true) }
  scope :enabled, -> { where(is_disabled: false) }

  scope :likes, -> { enabled.where(value: true) }
  scope :dislikes, -> { enabled.where(value: false) }

  def enable!
    update(is_disabled: false)
  end

  def disable!
    update(is_disabled: true)
  end
end
