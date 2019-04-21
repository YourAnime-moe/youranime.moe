class Subtitle < ApplicationRecord
  belongs_to :episode
  validates :lang, presence: true, inclusion: { in: ['en', 'fr', 'jp'] }
  validates :name, presence: true

  has_one_attached :src

  def self.languages
    [['English (default)', 'en'], ['Français', 'fr'], ['日本語', 'jp']]
  end
end
