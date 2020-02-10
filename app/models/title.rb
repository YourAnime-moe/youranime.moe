class Title < ApplicationRecord
  include TanoshimuUtils::Concerns::Translatable
  include TanoshimuUtils::Concerns::GetRecord

  validate :title_present
  validates :used_by_model, presence: true

  translates :value, through: [:en, :fr, :jp], default: :roman

  scope :search, lambda { |query, limit: nil|
    return all if query.empty?

    titles_to_search = %i[en fr jp roman]
    titles_as_queries = titles_to_search.map do |key|
      "(lower(titles.#{key}) like '%%#{query}%%')"
    end.join(' or ')
    where(titles_as_queries)
  }

  private
  
  def title_present
    errors.add(:value, 'must be present (one of en, fr, jp)') unless value.present?
  end
end
