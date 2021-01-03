# frozen_string_literal: true
class Upload < ApplicationRecord
  belongs_to :user
  has_one_attached :attachment

  validates :upload_filename, presence: true

  def initialize(*args)
    super
    self.uuid = SecureRandom.uuid
    self
  end

  def upload_filename
    "upload-#{upload_type}-#{uuid}"
  end
end
