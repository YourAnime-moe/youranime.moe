class Upload < ApplicationRecord
  belongs_to :user
  has_one_attached :attachment

  def initialize(*args)
    super
    self.uuid = SecureRandom.uuid
    self
  end
end
