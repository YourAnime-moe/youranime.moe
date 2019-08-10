class Issue < ApplicationRecord
  include ConnectsToShowsConcern
  
  validates :title, presence: true
  validates :description, presence: true
  validates :status, presence: true

  belongs_to :user, inverse_of: :issues
  validate :page_url_format

  PAGE_URL_FORMAT = /\A\/[\/\w-]+\z/

  private

  def page_url_format
    unless PAGE_URL_FORMAT === page_url
      errors.add(:page_url, 'is not valid. Did you add query parameters?')
    end
  end
end
