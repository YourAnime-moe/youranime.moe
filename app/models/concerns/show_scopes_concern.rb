# frozen_string_literal: true

module ShowScopesConcern
  extend ActiveSupport::Concern

  included do
    scope :by_season, ->(title) { published.where(title: title).order(:show_number) }
    scope :coming_soon, -> { where("publish_after is not null and publish_after > '#{Date.current}' ") }
    scope :published, -> { valid.where(published: true) }
    scope :recent, lambda { |limit: 50|
      limit = 1 if limit < 1
      sql = <<-SQL
        select shows.* from shows
        inner join episodes
        on shows.id = episodes.show_id
        where shows.published = 't'
        order by episodes.created_at desc
        limit ?;
      SQL
      find_by_sql([sql, limit])
    }
    scope :latest, lambda { |current_user, limit: 5|
      limit = 1 if limit < 1
      sql = <<-SQL
        select distinct shows.*
        from shows inner join (
          select ep.* from user_watch_progresses as up
          inner join episodes ep on up.episode_id = ep.id
          where up.user_id = ?
        ) as we on we.show_id = shows.id limit ?;
      SQL
      find_by_sql([sql, current_user.id, limit])
    }
    scope :trending, lambda { |limit: 6|
      sql = <<-SQL
        select sum(views) as views, shows.*
        from (
          select episodes.show_id, count(*) as views
          from episodes
          inner join user_watch_progresses up
          on up.episode_id = episodes.id
          where progress > 0
          group by episodes.id
          having count(*) > 0
          order by views desc limit 100
        ) as sv
        inner join shows
        on show_id = shows.id
        group by shows.id
        order by views desc
        limit ?;
      SQL
      find_by_sql([sql, limit])
    }
    scope :valid, lambda {
      roman_title_query = "(roman_title is not null and roman_title != '')"
      en_title_query = "(en_title is not null and en_title != '')"
      fr_title_query = "(fr_title is not null and fr_title != '')"
      jp_title_query = "(jp_title is not null and jp_title != '')"
      ordered.where("#{roman_title_query} and (#{en_title_query} or #{fr_title_query} or #{jp_title_query})")
    }
    scope :ordered, lambda {
      title_column = nil
      title_column = case I18n.locale
                    when :fr
                      'fr_title'
                    when :jp
                      'jp_title'
                    else
                      'en_title'
                    end
      order(:alternate_title).order(:roman_title).order("#{title_column} asc")
    }
    scope :search, lambda { |query, limit: nil|
      return published if query.empty?

      titles_to_search = %i[en_title fr_title jp_title alternate_title roman_title]
      titles_as_queries = titles_to_search.map { |key| "(lower(shows.#{key}) like '%%#{query}%%')" }.join(' or ')
      sql = <<-SQL
        select * from shows
        where (#{titles_as_queries})
        and shows.published = 't'
      SQL
      sql_args = [sql]
      sql_args << "limit #{limit}" unless limit.to_i == 0
      find_by_sql(sql_args)
    }
  end
end
