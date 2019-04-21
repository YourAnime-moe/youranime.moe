class Subtitle < ApplicationRecord
  belongs_to :episode
  validates :lang, presence: true
  validates :name, presence: true

  has_one_attached :src
end
