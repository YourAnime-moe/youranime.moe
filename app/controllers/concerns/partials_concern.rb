# frozen_string_literal: true

module PartialsConcern
  extend ActiveSupport::Concern

  def trending_shows_partial
    @trending = Show.trending.includes(:title_record).limit(8)

    render template: 'users/trending_shows', layout: false
  end

  def main_queue_partial
    @main_queue = current_user.main_queue.shows.limit(4)

    render template: 'users/main_queue', layout: false
  end

  def recommendations_partial
    @recommendations = Shows::Recommend.perform(user: current_user, limit: 8)

    render template: 'users/recommendations', layout: false
  end

  def recent_shows_partial
    episodes = Episode.published.includes(season: :show)
    ids = recent_shows_ids.uniq[0..(episodes.size.positive? ? 7 : 11)]
    @recent_shows = Show.recent.includes(:title_record).where(id: ids).limit(8)

    render template: 'users/recent_shows', layout: false
  end

  private

  def home_shows
    shows = Show.recent.limit(100)
    return shows if shows.any?

    Show.published
  end

  def recent_shows_ids
    home_shows.map(&:id)
  end
end
