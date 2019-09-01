class Title < ApplicationRecord
  include TranslatableConcern
  include GetRecordConcern

  validate :title_present
  validates :used_by_model, presence: true

  translates :value, through: [:en, :fr, :jp], default: :en

  scope :search, lambda { |query, limit: nil|
    return all if query.empty?

    titles_to_search = %i[en fr jp roman]
    titles_as_queries = titles_to_search.map { |key| "(lower(titles.#{key}) like '%%#{query}%%')" }.join(' or ')
    sql = <<-SQL
      select * from titles
      where (#{titles_as_queries})
    SQL
    sql_args = [sql]
    sql_args << "limit #{limit}" unless limit.to_i == 0
    find_by_sql(sql_args)
  }

  private
  
  def title_present
    errors.add(:value, 'must be present (one of en, fr, jp)') unless value.present?
  end
end
