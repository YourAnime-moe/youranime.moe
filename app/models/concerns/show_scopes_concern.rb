# frozen_string_literal: true

module ShowScopesConcern
  extend ActiveSupport::Concern

  included do
    scope :coming_soon, -> { where("publish_after is not null and publish_after > '#{Date.current}' ") }
    scope :recent, lambda { |limit: 50|
      limit = 1 if limit < 1
      includes(:seasons).where(published: true).order(:updated_at).limit(limit)
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
  end
end
